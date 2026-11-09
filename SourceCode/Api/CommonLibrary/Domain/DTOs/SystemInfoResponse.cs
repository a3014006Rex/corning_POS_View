namespace Corning.Pos.Domain.DTOs;

public sealed record SystemCapabilities(bool Database, bool DeviceGateway, bool Transactions);

public sealed record SystemInfoResponse(
    string Name,
    string Version,
    string Mode,
    DateTimeOffset ServerTime,
    SystemCapabilities Capabilities);
