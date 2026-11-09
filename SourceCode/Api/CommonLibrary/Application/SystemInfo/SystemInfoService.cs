using Corning.Pos.Domain.DTOs;

namespace Corning.Pos.Application.SystemInfo;

public sealed class SystemInfoService(TimeProvider timeProvider) : ISystemInfoService
{
    public SystemInfoResponse GetInfo() => new(
        "康寧餐卡 POS",
        typeof(SystemInfoService).Assembly.GetName().Version?.ToString(3) ?? "0.1.0",
        "Foundation",
        timeProvider.GetUtcNow(),
        new SystemCapabilities(Database: false, DeviceGateway: false, Transactions: false));
}
