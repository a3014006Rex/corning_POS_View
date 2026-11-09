using Corning.Pos.Domain.DTOs;

namespace Corning.Pos.Application.SystemInfo;

public interface ISystemInfoService
{
    SystemInfoResponse GetInfo();
}
