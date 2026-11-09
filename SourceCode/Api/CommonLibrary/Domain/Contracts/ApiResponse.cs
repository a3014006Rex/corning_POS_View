namespace Corning.Pos.Domain.Contracts;

public sealed record ApiErrorDetail(string Field, string Message);

public sealed record ApiResponse<T>(
    bool Success,
    string Code,
    T? Data,
    string? Message,
    string TraceId,
    IReadOnlyList<ApiErrorDetail>? Details = null)
{
    public static ApiResponse<T> Ok(T data, string traceId) =>
        new(true, "OK", data, null, traceId);

    public static ApiResponse<T> Fail(
        string code,
        string message,
        string traceId,
        IReadOnlyList<ApiErrorDetail>? details = null) =>
        new(false, code, default, message, traceId, details);
}
