using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Corning.Pos.Tests;

public sealed class SimulationClock : TimeProvider
{
    public DateTimeOffset Now { get; set; } = new(2026, 11, 8, 4, 0, 0, TimeSpan.Zero);
    public override DateTimeOffset GetUtcNow() => Now;
}

public sealed class SimulationFactory(string environment = "Development", bool enabled = true) : WebApplicationFactory<Program>
{
    public SimulationClock Clock { get; } = new();
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment(environment);
        builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
            new Dictionary<string, string?> { ["Development:EnableSimulation"] = enabled.ToString() }));
        builder.ConfigureServices(services =>
        {
            services.RemoveAll<TimeProvider>();
            services.AddSingleton<TimeProvider>(Clock);
        });
    }
}

public sealed class SimulationApiTests
{
    private static HttpClient Client(WebApplicationFactory<Program> factory)
    {
        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Add("X-TC-Simulation", "1");
        return client;
    }

    private static async Task<JsonElement> Post(HttpClient client, string path, object body)
    {
        using var response = await client.PostAsJsonAsync("/api/v1/development" + path, body);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("data");
    }

    private static async Task<(Guid Claim, Guid Quote)> Prepare(HttpClient client)
    {
        var receipt = await Post(client, "/swipes", new { operationId = Guid.NewGuid(), scenarioId = "employee-a" });
        var claim = await Post(client, "/claims", new { eventId = receipt.GetProperty("eventId").GetGuid() });
        var claimId = claim.GetProperty("claimId").GetGuid();
        var quote = await Post(client, "/quotes", new { claimId, totalAmountMinor = 8000 });
        Assert.Equal("NOT_EVALUATED", quote.GetProperty("allocationStatus").GetString());
        return (claimId, quote.GetProperty("quoteId").GetGuid());
    }

    [Fact]
    public async Task ConfirmLookupAndListUseTheSameSimulatedRecord()
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        var (claim, quote) = await Prepare(client);
        var clientId = Guid.NewGuid();
        var result = await Post(client, "/transactions", new { clientTransactionId = clientId, claimId = claim, quoteId = quote });
        Assert.Equal("SIMULATED", result.GetProperty("status").GetString());
        Assert.Equal(8000, result.GetProperty("totalAmountMinor").GetInt64());
        var found = await client.GetFromJsonAsync<JsonElement>($"/api/v1/development/transactions/by-client-id/{clientId}");
        Assert.Equal(result.GetProperty("transactionId").GetGuid(), found.GetProperty("data").GetProperty("transactionId").GetGuid());
        var rows = await client.GetFromJsonAsync<JsonElement>("/api/v1/development/transactions");
        Assert.Single(rows.GetProperty("data").EnumerateArray());
        Assert.DoesNotContain("0000000101", result.GetRawText());
    }

    [Fact]
    public async Task SameIdRetriesRemainSuccessfulAfterClaimAndQuoteExpiry()
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        var (claim, quote) = await Prepare(client);
        var body = new { clientTransactionId = Guid.NewGuid(), claimId = claim, quoteId = quote };
        var original = await Post(client, "/transactions", body);
        factory.Clock.Now = factory.Clock.Now.AddHours(1);
        var results = await Task.WhenAll(Enumerable.Range(0, 8).Select(_ => Post(client, "/transactions", body)));
        Assert.All(results, value => Assert.Equal(original.GetRawText(), value.GetRawText()));
        var list = await client.GetFromJsonAsync<JsonElement>("/api/v1/development/transactions");
        Assert.Single(list.GetProperty("data").EnumerateArray());
        using var conflict = await client.PostAsJsonAsync("/api/v1/development/transactions", new { body.clientTransactionId, claimId = claim, quoteId = Guid.NewGuid() });
        Assert.Equal(HttpStatusCode.Conflict, conflict.StatusCode);
    }

    [Fact]
    public async Task NewPersonCannotReplaceAnActiveClaimAndCancelReleasesIt()
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        var (claim, _) = await Prepare(client);
        var next = await Post(client, "/swipes", new { operationId = Guid.NewGuid(), scenarioId = "employee-b" });
        var nextBody = new { eventId = next.GetProperty("eventId").GetGuid() };
        using var rejected = await client.PostAsJsonAsync("/api/v1/development/claims", nextBody);
        Assert.Equal(HttpStatusCode.Conflict, rejected.StatusCode);
        var error = await rejected.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("CURRENT_PERSON_ACTIVE", error.GetProperty("code").GetString());
        await Post(client, $"/claims/{claim}/release", new { });
        var second = await Post(client, "/claims", nextBody);
        Assert.Equal("SYNTH00000002", second.GetProperty("person").GetProperty("employeeCode").GetString());
    }

    [Fact]
    public async Task SupersededOrExpiredQuotesCannotCreateRecords()
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        var (claim, quote) = await Prepare(client);
        var newer = await Post(client, "/quotes", new { claimId = claim, totalAmountMinor = 9000 });
        using var old = await client.PostAsJsonAsync("/api/v1/development/transactions", new { clientTransactionId = Guid.NewGuid(), claimId = claim, quoteId = quote });
        Assert.Equal(HttpStatusCode.Conflict, old.StatusCode);
        factory.Clock.Now = factory.Clock.Now.AddMinutes(3);
        using var expired = await client.PostAsJsonAsync("/api/v1/development/transactions", new { clientTransactionId = Guid.NewGuid(), claimId = claim, quoteId = newer.GetProperty("quoteId").GetGuid() });
        Assert.Equal(HttpStatusCode.Gone, expired.StatusCode);
        var rows = await client.GetFromJsonAsync<JsonElement>("/api/v1/development/transactions");
        Assert.Empty(rows.GetProperty("data").EnumerateArray());
    }

    [Theory]
    [InlineData("revoked")]
    [InlineData("unknown")]
    public async Task InvalidSyntheticCardsAreRejected(string scenario)
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        using var response = await client.PostAsJsonAsync("/api/v1/development/swipes", new { operationId = Guid.NewGuid(), scenarioId = scenario });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }

    [Theory]
    [InlineData("Production", true)]
    [InlineData("Development", false)]
    public async Task DisabledSimulationHasNoEndpoints(string environment, bool enabled)
    {
        await using var factory = new SimulationFactory(environment, enabled);
        using var client = Client(factory);
        using var response = await client.GetAsync("/api/v1/development/scenarios");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task DevelopmentEndpointsRejectMissingMarkerAndForeignOrigin()
    {
        await using var factory = new SimulationFactory();
        using var client = factory.CreateClient();
        using var noHeader = await client.GetAsync("/api/v1/development/scenarios");
        Assert.Equal(HttpStatusCode.Forbidden, noHeader.StatusCode);
        client.DefaultRequestHeaders.Add("X-TC-Simulation", "1");
        client.DefaultRequestHeaders.Add("Origin", "https://foreign.example");
        using var foreign = await client.GetAsync("/api/v1/development/scenarios");
        Assert.Equal(HttpStatusCode.Forbidden, foreign.StatusCode);
    }

    [Fact]
    public async Task InvalidJsonAndEmptyIdsUseTheErrorEnvelope()
    {
        await using var factory = new SimulationFactory();
        using var client = Client(factory);
        using var malformed = await client.PostAsync("/api/v1/development/swipes", new StringContent("{", Encoding.UTF8, "application/json"));
        Assert.Equal(HttpStatusCode.BadRequest, malformed.StatusCode);
        var body = await malformed.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("INVALID_REQUEST", body.GetProperty("code").GetString());
        using var empty = await client.PostAsJsonAsync("/api/v1/development/swipes", new { operationId = Guid.Empty, scenarioId = "employee-a" });
        Assert.Equal(HttpStatusCode.BadRequest, empty.StatusCode);
    }
}
