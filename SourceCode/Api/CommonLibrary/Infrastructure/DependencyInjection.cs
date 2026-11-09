using Corning.Pos.Application.SystemInfo;
using Microsoft.Extensions.DependencyInjection;

namespace Corning.Pos.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<ISystemInfoService, SystemInfoService>();
        return services;
    }
}
