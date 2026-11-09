using System.Net;
using System.Text.Json;
using Corning.Pos.Application.Simulation;
using Corning.Pos.Domain.Contracts;

namespace Corning.Pos.Api.Development;

public static class SimulationRoutes
{
    public static bool IsEnabled(IHostEnvironment environment, IConfiguration configuration) =>
        environment.IsDevelopment() && configuration.GetValue<bool>("Development:EnableSimulation");

    public static void MapSimulation(this WebApplication app)
    {
        if (!IsEnabled(app.Environment, app.Configuration)) return;
        var group = app.MapGroup("/api/v1/development").AllowAnonymous().ExcludeFromDescription();
        group.AddEndpointFilter(async (context, next) =>
        {
            var http = context.HttpContext;
            var address = http.Connection.RemoteIpAddress;
            var origin = http.Request.Headers.Origin.ToString();
            var localOrigin = string.IsNullOrEmpty(origin) ||
                (Uri.TryCreate(origin, UriKind.Absolute, out var uri) &&
                 (uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
                  IPAddress.TryParse(uri.Host, out var ip) && IPAddress.IsLoopback(ip)));
            if ((address is not null && !IPAddress.IsLoopback(address)) || !localOrigin ||
                http.Request.Headers["X-TC-Simulation"] != "1")
                return Error(http, 403, "DEVELOPMENT_ONLY", "僅允許本機開發用模擬請求。 ");
            try { return await next(context); }
            catch (SimulationException failure)
            {
                var status = failure.Code switch
                {
                    "INVALID_REQUEST" or "INVALID_AMOUNT" => 400,
                    "CARD_INVALID" => 422,
                    "EVENT_NOT_FOUND" or "CLAIM_NOT_FOUND" or "QUOTE_NOT_FOUND" or "TRANSACTION_NOT_FOUND" => 404,
                    "CLAIM_EXPIRED" or "QUOTE_EXPIRED" => 410,
                    _ => 409
                };
                return Error(http, status, failure.Code, failure.Message);
            }
        });
        group.MapGet("/scenarios", (HttpContext http, SimulationWorkflow workflow) => Ok(http, workflow.GetScenarios()));
        group.MapPost("/swipes", (HttpContext http, SimulationWorkflow workflow) =>
            Read<SimulateSwipeRequest>(http, value => workflow.Swipe(value.OperationId, value.ScenarioId)));
        group.MapPost("/claims", (HttpContext http, SimulationWorkflow workflow) =>
            Read<SimulateClaimRequest>(http, value => workflow.Claim(value.EventId)));
        group.MapPost("/claims/{claimId:guid}/release", (Guid claimId, HttpContext http, SimulationWorkflow workflow) => Ok(http, workflow.Release(claimId)));
        group.MapPost("/quotes", (HttpContext http, SimulationWorkflow workflow) =>
            Read<SimulateQuoteRequest>(http, value => workflow.Quote(value.ClaimId, value.TotalAmountMinor)));
        group.MapPost("/transactions", (HttpContext http, SimulationWorkflow workflow) =>
            Read<SimulateCommitRequest>(http, value => workflow.Commit(value.ClientTransactionId, value.ClaimId, value.QuoteId)));
        group.MapGet("/transactions/by-client-id/{clientId:guid}", (Guid clientId, HttpContext http, SimulationWorkflow workflow) => Ok(http, workflow.Find(clientId)));
        group.MapGet("/transactions", (HttpContext http, SimulationWorkflow workflow) => Ok(http, workflow.List()));
    }

    private static async Task<IResult> Read<T>(HttpContext http, Func<T, object> action)
    {
        if (!http.Request.HasJsonContentType()) return Error(http, 415, "INVALID_REQUEST", "請使用 JSON 請求。 ");
        try
        {
            var value = await http.Request.ReadFromJsonAsync<T>(http.RequestAborted);
            return value is null ? Error(http, 400, "INVALID_REQUEST", "請求不可為空。 ") : Ok(http, action(value));
        }
        catch (JsonException) { return Error(http, 400, "INVALID_REQUEST", "JSON 欄位或格式不正確。 "); }
    }

    private static IResult Ok(HttpContext http, object value) => Results.Json(ApiResponse<object>.Ok(value, http.TraceIdentifier));
    private static IResult Error(HttpContext http, int status, string code, string message) =>
        Results.Json(ApiResponse<object>.Fail(code, message.Trim(), http.TraceIdentifier), statusCode: status);
}
