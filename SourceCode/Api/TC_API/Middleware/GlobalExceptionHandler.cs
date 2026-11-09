using Corning.Pos.Domain.Contracts;
using Microsoft.AspNetCore.Diagnostics;

namespace Corning.Pos.Api.Middleware;

public sealed class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        logger.LogError(exception, "Unhandled request failure. TraceId: {TraceId}", httpContext.TraceIdentifier);
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(
            ApiResponse<object>.Fail("INTERNAL_ERROR", "服務暫時無法處理請求，請提供追蹤編號供查詢。", httpContext.TraceIdentifier),
            cancellationToken);
        return true;
    }
}
