using System.Text.Json;
using System.Text.Json.Serialization;
using Corning.Pos.Api.Authentication;
using Corning.Pos.Api.Middleware;
using Corning.Pos.Api.Development;
using Corning.Pos.Application.Simulation;
using Corning.Pos.Domain.Contracts;
using Corning.Pos.Infrastructure;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplication();
if (SimulationRoutes.IsEnabled(builder.Environment, builder.Configuration))
    builder.Services.AddSingleton<SimulationWorkflow>();
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});
builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var details = context.ModelState
            .Where(item => item.Value?.Errors.Count > 0)
            .SelectMany(item => item.Value!.Errors.Select(error =>
                new ApiErrorDetail(item.Key, string.IsNullOrEmpty(error.ErrorMessage) ? "欄位格式不正確。" : error.ErrorMessage)))
            .ToArray();
        return new BadRequestObjectResult(ApiResponse<object>.Fail(
            "INVALID_REQUEST", "請確認輸入欄位。", context.HttpContext.TraceIdentifier, details));
    };
});
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAuthentication(PendingIdentityHandler.SchemeName)
    .AddScheme<AuthenticationSchemeOptions, PendingIdentityHandler>(PendingIdentityHandler.SchemeName, _ => { });
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build();
});
var origins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("Web", policy =>
{
    if (origins.Length > 0)
    {
        policy.WithOrigins(origins).AllowAnyHeader().AllowAnyMethod();
    }
}));

var app = builder.Build();
app.Use(async (context, next) =>
{
    context.Response.Headers["X-Trace-Id"] = context.TraceIdentifier;
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    await next(context);
});
app.UseExceptionHandler();
app.UseStatusCodePages(async context =>
{
    var statusCode = context.HttpContext.Response.StatusCode;
    var (code, message) = statusCode switch
    {
        401 => ("UNAUTHENTICATED", "尚未建立正式身分驗證，無法存取此功能。"),
        403 => ("OUT_OF_SCOPE", "沒有此功能的存取權限。"),
        404 => ("NOT_FOUND", "找不到指定資源。"),
        405 => ("METHOD_NOT_ALLOWED", "此端點不支援指定的 HTTP 方法。"),
        _ => ("HTTP_ERROR", "請求未能完成。")
    };
    await context.HttpContext.Response.WriteAsJsonAsync(
        ApiResponse<object>.Fail(code, message, context.HttpContext.TraceIdentifier));
});
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseRouting();
app.UseCors("Web");
app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/health/live", () => Results.Ok(new { status = "Alive", scope = "Process" }))
    .AllowAnonymous();
app.MapControllers();
app.MapSimulation();
app.MapFallback("/{**path}", () => Results.NotFound()).AllowAnonymous();
app.Run();

public partial class Program;
