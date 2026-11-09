using System.Text.Json;
using System.Diagnostics.CodeAnalysis;

namespace Corning.Pos.Application.Simulation;

// T05 開發用模擬器：固定合成資料、程序記憶體、單一測試終端。
// 不處理正式設備 frame、不連 DB、不計算未核准補助，也不取代 T06 的 SQL 交易。
public sealed class SimulationWorkflow(TimeProvider clock)
{
    private const int MaxRecords = 500;
    private readonly object gate = new();
    private readonly Dictionary<Guid, SimulationEvent> receipts = [];
    private readonly Dictionary<Guid, SimulationEvent> events = [];
    private readonly Dictionary<Guid, SimulationClaim> claims = [];
    private readonly Dictionary<Guid, SimulationQuote> quotes = [];
    private readonly Dictionary<Guid, Guid> currentQuotes = [];
    private readonly Dictionary<Guid, SimulationTransaction> transactions = [];
    private readonly HashSet<Guid> consumedEvents = [];
    private Guid? activeClaimId;
    private readonly SyntheticScenario[] scenarios = LoadScenarios();

    public IReadOnlyList<object> GetScenarios() => scenarios.Select(item => (object)new
    {
        item.Id, item.EmployeeCode, item.Name, item.IdentityType, item.Enabled
    }).ToArray();

    public SimulationEvent Swipe(Guid operationId, string scenarioId)
    {
        lock (gate)
        {
            RequireId(operationId);
            if (receipts.TryGetValue(operationId, out var existing))
            {
                if (existing.ScenarioId != scenarioId) Fail("IDEMPOTENCY_CONFLICT", "相同事件操作編號不可改用另一張卡。 ");
                return existing;
            }
            var scenario = scenarios.SingleOrDefault(item => item.Id == scenarioId);
            if (scenario is null || !scenario.Enabled) Fail("CARD_INVALID", "此合成卡不存在或已撤銷，未建立交易。 ");
            RequireCapacity(events.Count);
            var person = new SimulationPerson(scenario!.EmployeeCode, scenario.Name, $"••••••{scenario.CardCode[^4..]}", scenario.IdentityType);
            var receipt = new SimulationEvent(Guid.NewGuid(), scenarioId, clock.GetUtcNow(), person);
            receipts.Add(operationId, receipt);
            events.Add(receipt.EventId, receipt);
            return receipt;
        }
    }

    public SimulationClaim Claim(Guid eventId)
    {
        lock (gate)
        {
            RequireId(eventId);
            if (!events.TryGetValue(eventId, out var receipt)) Fail("EVENT_NOT_FOUND", "找不到測試事件。 ");
            if (consumedEvents.Contains(eventId)) Fail("EVENT_CONSUMED", "此刷卡事件已用於測試紀錄。 ");
            if (activeClaimId is Guid id && claims[id].ExpiresAt > clock.GetUtcNow())
            {
                if (claims[id].EventId == eventId) return claims[id];
                Fail("CURRENT_PERSON_ACTIVE", "請先完成或取消目前這位人員，新刷卡不會覆蓋當前身分。 ");
            }
            RequireCapacity(claims.Count);
            var claim = new SimulationClaim(Guid.NewGuid(), eventId, clock.GetUtcNow().AddMinutes(5), receipt!.Person);
            claims.Add(claim.ClaimId, claim);
            activeClaimId = claim.ClaimId;
            return claim;
        }
    }

    public object Release(Guid claimId)
    {
        lock (gate)
        {
            RequireId(claimId);
            if (!claims.ContainsKey(claimId)) Fail("CLAIM_NOT_FOUND", "找不到此測試領取。 ");
            if (activeClaimId == claimId) activeClaimId = null;
            return new { State = "RELEASED", ClaimId = claimId };
        }
    }

    public SimulationQuote Quote(Guid claimId, long amountMinor)
    {
        lock (gate)
        {
            GetActiveClaim(claimId);
            if (amountMinor is <= 0 or > 9_007_199_254_740_991) Fail("INVALID_AMOUNT", "測試金額必須為安全範圍內的正整數最小貨幣單位。 ");
            RequireCapacity(quotes.Count);
            var quote = new SimulationQuote(Guid.NewGuid(), claimId, amountMinor, "TWD", clock.GetUtcNow().AddMinutes(2));
            quotes.Add(quote.QuoteId, quote);
            currentQuotes[claimId] = quote.QuoteId;
            return quote;
        }
    }

    public SimulationTransaction Commit(Guid clientId, Guid claimId, Guid quoteId)
    {
        lock (gate)
        {
            RequireId(clientId);
            // 先查原結果，避免已成功的重試被目前的有效期或身分變更錯誤拒絕。
            if (transactions.TryGetValue(clientId, out var previous))
            {
                if (previous.ClaimId != claimId || previous.QuoteId != quoteId) Fail("IDEMPOTENCY_CONFLICT", "相同交易編號的內容不同，請查詢原紀錄。 ");
                return previous;
            }
            var claim = GetActiveClaim(claimId);
            if (!quotes.TryGetValue(quoteId, out var quote) || quote.ClaimId != claimId) Fail("QUOTE_NOT_FOUND", "找不到此測試報價。 ");
            if (quote!.ExpiresAt <= clock.GetUtcNow()) Fail("QUOTE_EXPIRED", "測試報價已過期，請重新確認金額。 ");
            if (currentQuotes.GetValueOrDefault(claimId) != quoteId) Fail("QUOTE_CHANGED", "金額已重新報價，請使用最新確認內容。 ");
            if (consumedEvents.Contains(claim.EventId)) Fail("EVENT_CONSUMED", "此刷卡事件已被使用。 ");
            RequireCapacity(transactions.Count);
            var transaction = new SimulationTransaction(Guid.NewGuid(), clientId, claimId, quoteId,
                quote.TotalAmountMinor, quote.Currency, clock.GetUtcNow(), claim.Person);
            transactions.Add(clientId, transaction);
            consumedEvents.Add(claim.EventId);
            activeClaimId = null;
            return transaction;
        }
    }

    public SimulationTransaction Find(Guid clientId)
    {
        lock (gate)
        {
            if (!transactions.TryGetValue(clientId, out var result)) Fail("TRANSACTION_NOT_FOUND", "此程序記憶體中尚無該測試交易；服務重啟會清除模擬資料。 ");
            return result!;
        }
    }

    public IReadOnlyList<SimulationTransaction> List()
    {
        lock (gate) return transactions.Values.OrderByDescending(item => item.RecordedAt).ToArray();
    }

    private SimulationClaim GetActiveClaim(Guid claimId)
    {
        RequireId(claimId);
        if (!claims.TryGetValue(claimId, out var claim)) Fail("CLAIM_NOT_FOUND", "找不到此測試領取。 ");
        if (claim!.ExpiresAt <= clock.GetUtcNow()) Fail("CLAIM_EXPIRED", "測試領取已過期，請重新刷測試卡。 ");
        if (activeClaimId != claimId) Fail("CLAIM_INACTIVE", "此測試領取已取消、完成或被更新。 ");
        return claim;
    }

    private static SyntheticScenario[] LoadScenarios()
    {
        using var stream = typeof(SimulationWorkflow).Assembly.GetManifestResourceStream("Corning.Pos.SyntheticScenarios.json")
            ?? throw new InvalidOperationException("缺少合成測試資料。");
        return JsonSerializer.Deserialize<SyntheticScenario[]>(stream, new JsonSerializerOptions(JsonSerializerDefaults.Web))
            ?? throw new InvalidOperationException("合成測試資料格式不正確。");
    }

    private static void RequireId(Guid id) { if (id == Guid.Empty) Fail("INVALID_REQUEST", "必須提供非空白的操作／事件編號。 "); }
    private static void RequireCapacity(int count) { if (count >= MaxRecords) Fail("SIMULATION_FULL", "測試資料已達容量，請重啟開發服務後再測。 "); }
    [DoesNotReturn]
    private static void Fail(string code, string message) => throw new SimulationException(code, message.Trim());
}
