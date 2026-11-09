using Corning.Pos.Application.SystemInfo;
using Corning.Pos.Domain.Contracts;
using Corning.Pos.Domain.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Corning.Pos.Api.Controllers;

[ApiController]
[Route("api/v1/system")]
public sealed class SystemController(ISystemInfoService systemInfoService) : ControllerBase
{
    [HttpGet("info")]
    [AllowAnonymous]
    [ProducesResponseType<ApiResponse<SystemInfoResponse>>(StatusCodes.Status200OK)]
    public ActionResult<ApiResponse<SystemInfoResponse>> GetInfo() =>
        Ok(ApiResponse<SystemInfoResponse>.Ok(systemInfoService.GetInfo(), HttpContext.TraceIdentifier));
}
