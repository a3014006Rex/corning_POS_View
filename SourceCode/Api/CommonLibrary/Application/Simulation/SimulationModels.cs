namespace Corning.Pos.Application.Simulation;

public sealed record SyntheticScenario(string Id, string EmployeeCode, string Name, string CardCode, string IdentityType, bool Enabled);
public sealed record SimulationPerson(string EmployeeCode, string Name, string CardCode, string IdentityType);
public sealed record SimulationEvent(Guid EventId, string ScenarioId, DateTimeOffset OccurredAt, SimulationPerson Person);
public sealed record SimulationClaim(Guid ClaimId, Guid EventId, DateTimeOffset ExpiresAt, SimulationPerson Person);
public sealed record SimulationQuote(Guid QuoteId, Guid ClaimId, long TotalAmountMinor, string Currency, DateTimeOffset ExpiresAt, string AllocationStatus = "NOT_EVALUATED");
public sealed record SimulationTransaction(Guid TransactionId, Guid ClientTransactionId, Guid ClaimId, Guid QuoteId, long TotalAmountMinor, string Currency, DateTimeOffset RecordedAt, SimulationPerson Person, string Status = "SIMULATED");

public sealed class SimulationException(string code, string message) : Exception(message)
{
    public string Code { get; } = code;
}

public sealed class SimulateSwipeRequest
{
    public Guid OperationId { get; init; }
    public string ScenarioId { get; init; } = "";
}
public sealed class SimulateClaimRequest { public Guid EventId { get; init; } }
public sealed class SimulateQuoteRequest
{
    public Guid ClaimId { get; init; }
    public long TotalAmountMinor { get; init; }
}
public sealed class SimulateCommitRequest
{
    public Guid ClientTransactionId { get; init; }
    public Guid ClaimId { get; init; }
    public Guid QuoteId { get; init; }
}
