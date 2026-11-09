using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace Corning.Pos.Tests;

public sealed class FoundationApiFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.ConfigureServices(services =>
            services.AddControllers().AddApplicationPart(typeof(ProbeController).Assembly));
    }
}

public sealed class FoundationApiTests(FoundationApiFactory factory) : IClassFixture<FoundationApiFactory>
{
    [Fact]
    public async Task SystemInfoReportsFoundationWithoutTransactionCapabilities()
    {
        using var client = factory.CreateClient();
        using var response = await client.GetAsync("/api/v1/system/info");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(body.GetProperty("success").GetBoolean());
        Assert.Equal("OK", body.GetProperty("code").GetString());
        Assert.Equal(response.Headers.GetValues("X-Trace-Id").Single(), body.GetProperty("traceId").GetString());
        var info = body.GetProperty("data");
        Assert.Equal("Foundation", info.GetProperty("mode").GetString());
        foreach (var capability in info.GetProperty("capabilities").EnumerateObject())
        {
            Assert.False(capability.Value.GetBoolean());
        }
        Assert.True(info.GetProperty("serverTime").GetDateTimeOffset() > DateTimeOffset.UtcNow.AddMinutes(-1));
    }

    [Fact]
    public async Task LivenessOnlyIndicatesProcessHealth()
    {
        using var client = factory.CreateClient();
        var body = await client.GetFromJsonAsync<JsonElement>("/health/live");
        Assert.Equal("Alive", body.GetProperty("status").GetString());
        Assert.Equal("Process", body.GetProperty("scope").GetString());
    }

    [Fact]
    public async Task FutureControllersRequireIdentityByDefault()
    {
        using var client = factory.CreateClient();
        using var response = await client.GetAsync("/__tests/protected");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.False(body.GetProperty("success").GetBoolean());
        Assert.Equal("UNAUTHENTICATED", body.GetProperty("code").GetString());
    }

    [Fact]
    public async Task UnknownRouteUsesErrorEnvelope()
    {
        using var client = factory.CreateClient();
        using var response = await client.GetAsync("/api/v1/missing");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("NOT_FOUND", body.GetProperty("code").GetString());
    }

    [Fact]
    public async Task ValidationUsesErrorEnvelopeAndFieldDetails()
    {
        using var client = factory.CreateClient();
        using var response = await client.PostAsJsonAsync("/__tests/validate", new { });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("INVALID_REQUEST", body.GetProperty("code").GetString());
        Assert.NotEmpty(body.GetProperty("details").EnumerateArray());
    }

    [Fact]
    public async Task ExceptionDetailsAreNotExposedToClients()
    {
        using var client = factory.CreateClient();
        using var response = await client.GetAsync("/__tests/throw");
        Assert.Equal(HttpStatusCode.InternalServerError, response.StatusCode);
        var text = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("private-test-detail", text);
        Assert.Equal("INTERNAL_ERROR", JsonDocument.Parse(text).RootElement.GetProperty("code").GetString());
    }
}

// 僅由測試 Host 載入，不會進入正式 API assembly。
[ApiController]
[Route("__tests")]
public sealed class ProbeController : ControllerBase
{
    [HttpGet("protected")]
    public IActionResult Protected() => Ok();

    [HttpPost("validate")]
    [AllowAnonymous]
    public IActionResult Validate(ProbeRequest request) => Ok(request);

    [HttpGet("throw")]
    [AllowAnonymous]
    public IActionResult Throw() => throw new InvalidOperationException("private-test-detail");
}

public sealed class ProbeRequest
{
    [Required]
    public string? Name { get; init; }
}
