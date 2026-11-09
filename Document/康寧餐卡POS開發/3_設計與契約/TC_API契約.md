# TC API 契約草案

版本 v1.0。E01–E42 是本案建議 API，均尚未實作；不是從現有程式查得的路由。T04 決定 Host、認證與正式 API 風格，後續更新本檔及追溯表。

2026-11-07 T04 更新：已建立 `/api/v1` 與 camelCase 回應基礎。實際新增 `GET /api/v1/system/info`（名稱、版本、UTC 時間、Foundation 能力旗標）及 `GET /health/live`（僅程序存活，獨立 health 格式）；兩者不是 E01–E42 業務 API。Development 提供 Swagger。認證尚未完成，其他 Controller 預設拒絕存取；E01–E42 仍待實作。見[執行步驟](../4_測試與執行/TC_執行與偵錯步驟.md)。

<a id="development-simulation"></a>
## 2026-11-08 開發模擬 API（T05）

以下已實作於獨立 `/api/v1/development` 命名空間，**不是 E01–E42 的正式實作**。僅在 `ASPNETCORE_ENVIRONMENT=Development` 且 `Development:EnableSimulation=true` 映射，還需本機來源、可接受的本機 Origin 與 `X-TC-Simulation: 1`；Production 即使旗標為 true 也回 404。正式 Controller 的預設拒絕授權未放寬。

| 方法／相對於 `/api/v1/development` | 輸入 | 輸出／用途 |
|---|---|---|
| `GET /scenarios` | 無 | 固定合成員工／卡片情境，不含完整卡碼 |
| `POST /swipes` | `operationId`, `scenarioId` | 原始模擬事件 ID、UTC 時間、遮罩身分；撤銷／未知情境 422 |
| `POST /claims` | `eventId` | Claim、5 分鐘測試到期、身分；未完成的人員不能被新刷卡覆蓋 |
| `POST /claims/{claimId}/release` | 空 JSON | 釋放測試領取 |
| `POST /quotes` | `claimId`, `totalAmountMinor` | Quote、TWD 總額、2 分鐘測試到期、`allocationStatus=NOT_EVALUATED` |
| `POST /transactions` | `clientTransactionId`, `claimId`, `quoteId` | 建立 `status=SIMULATED`；相同 ID／內容回原紀錄，不同內容 409 |
| `GET /transactions/by-client-id/{clientId}` | UUID | 查原結果；此程序無紀錄則 404 |
| `GET /transactions` | 無 | 本程序測試紀錄，供開發後台與 CSV |

沿用 camelCase envelope、HTTP 狀態及 traceId；格式錯誤 400、過期 410、狀態／ID 衝突 409。模擬資料只在單一程序記憶體，事件／Claim／Quote／交易各最多 500 筆，滿額需重啟開發服務；Claim／Quote 租約僅為測試值。沒有 SQL 原子性、正式資格分攤或多終端權限。前端保存 UUID 後才提交，未知結果不建立另一 ID，先查原單。

## 共通契約

- 路由版本：提案 `/api/v1`。不沿用 M10 的固定路由與專用權限 Attribute。
- HTTPS 與受信任服務／裝置身分。後台角色、SiteId/LaneId 範圍及終端身分皆由服務端驗證。
- 時間採含 offset 的 ISO 8601；BusinessDate 採 `yyyy-MM-dd`，廠區時區明列。卡號為字串並保留前導零。
- 金額採 `Currency="TWD"` 與最小貨幣單位整數，例如 NT$80.00 為 `TotalAmountMinor=8000`。金額以 Int64 儲存並限制業務上限；API/前端需確保安全整數範圍。舊 int 欄位不可未確認語意就乘 100 搬入。
- 變更操作帶 OperationId 或 ClientTransactionId，並對固定身份範圍實施唯一性與請求內容雜湊。E17 的 Idempotency-Key（若使用）必須與 ClientTransactionId 一致。網路 RequestId 只供追蹤，不作交易去重。
- 寫入資料帶 ExpectedVersion；版本不符回衝突。已發布費用規則建立新版本，不覆寫歷史。
- 分頁需驗證 Page/PageSize 與最大範圍；查詢與下載都受權限限制。
- 輸出草案：成功 `{success:true,code:"OK",data:{...},traceId:"..."}`；失敗 `{success:false,code:"...",message:"...",details:[],traceId:"..."}`。HTTP 狀態與業務碼一致，不能 HTTP 200 就當業務成功。

## API 總覽

| ID | 方法／路由（提案） | 角色／服務 | 需求／工作 |
|---|---|---|---|
| [E01](#e01) | `GET /api/v1/employees` | HR／餐務查詢 | TC-01-01；T08 |
| [E02](#e02) | `POST /api/v1/employees/import-jobs` | HR 維護 | TC-01-01；T08 |
| [E03](#e03) | `POST /api/v1/card-assignments` | 卡務 | TC-01-02；T09 |
| [E04](#e04) | `POST /api/v1/card-assignments/{id}/revoke` | 卡務 | TC-01-02；T09 |
| [E05](#e05) | `POST /api/v1/temporary-card-loans` | 卡務 | TC-01-03；T10 |
| [E06](#e06) | `POST /api/v1/temporary-card-loans/{id}/return` | 卡務 | TC-01-03；T10 |
| [E07](#e07) | `PUT /api/v1/subsidy-eligibilities/{id}` | 餐務設定 | TC-01-04；T12 |
| [E08](#e08) | `PUT /api/v1/meal-periods/{id}` | 餐務設定 | TC-01-05；T11 |
| [E09](#e09) | `PUT /api/v1/lanes/{id}/bindings` | 設備設定 | TC-01-06；T13 |
| [E10](#e10) | `GET /api/v1/devices/status` | 設備查詢 | TC-02-01；T14、T30 |
| [E11](#e11) | `POST /api/v1/gateway/swipe-events/batch` | Gateway 裝置 | TC-02-02、TC-02-03；T15、T16 |
| [E12](#e12) | `POST /api/v1/devices/{id}/card-sync-jobs` | 卡務／授權工作服務 | TC-02-04；T25 |
| [E13](#e13) | `GET /api/v1/devices/{id}/card-sync-jobs/{jobId}` | 卡務／設備查詢 | TC-02-04；T25 |
| [E14](#e14) | `POST /api/v1/pos/swipe-events/claim` | 授權 POS | TC-03-01；T17 |
| [E15](#e15) | `POST /api/v1/pos/swipe-events/{id}/release` | 原領取 POS | TC-03-01；T17 |
| [E16](#e16) | `POST /api/v1/pos/quotes` | 原領取 POS | TC-03-02；T18 |
| [E17](#e17) | `POST /api/v1/pos/transactions` | 原領取 POS | TC-03-03；T19、T20 |
| [E18](#e18) | `GET /api/v1/pos/transactions/by-client-id/{clientId}` | 原 POS／授權主管 | TC-03-03；T19、T20 |
| [E19](#e19) | `POST /api/v1/transactions/{id}/reversals` | 沖正授權主管 | TC-03-04；T21 |
| [E20](#e20) | `POST /api/v1/transactions/{id}/replacement-drafts` | 更正授權主管 | TC-03-04；T21 |
| [E21](#e21) | `GET /api/v1/pos/operating-status` | 授權 POS | TC-03-05；T22、T30 |
| [E22](#e22) | `GET /api/v1/transactions` | 餐務查詢 | TC-04-01；T23 |
| [E23](#e23) | `POST /api/v1/manual-adjustments` | 補登授權者 | TC-04-02；T23 |
| [E24](#e24) | `GET /api/v1/exceptions` | 餐務／維運查詢 | TC-04-03；T24 |
| [E25](#e25) | `POST /api/v1/exceptions/{id}/resolutions` | 異常處理者 | TC-04-03；T24 |
| [E26](#e26) | `PUT /api/v1/subsidy-rules/{id}` | 餐補設定者 | TC-04-04；T12、T20 |
| [E27](#e27) | `PUT /api/v1/roles/{id}/permissions` | 權限管理者 | TC-04-05；T07 |
| [E28](#e28) | `GET /api/v1/audit-logs` | 稽核查詢 | TC-04-06；T24 |
| [E29](#e29) | `POST /api/v1/reports/employee-costs/export-jobs` | 財務／匯出權限 | TC-05-01；T26 |
| [E30](#e30) | `POST /api/v1/settlement-batches` | 結算建立者 | TC-05-02；T27 |
| [E31](#e31) | `POST /api/v1/settlement-batches/{id}/confirm` | 結算確認者 | TC-05-02；T27 |
| [E32](#e32) | `GET /api/v1/reports/meal-counts` | 餐務統計 | TC-05-03；T28 |
| [E33](#e33) | `POST /api/v1/integrations/hr-sync-jobs` | HR／整合服務 | TC-05-04；T08、T25 |
| [E34](#e34) | `GET /api/v1/integrations/jobs/{id}` | 整合查詢 | TC-05-04；T08、T25 |
| [E35](#e35) | `POST /api/v1/migration-runs` | 限移轉環境／DBA | TC-05-05；T29 |
| [E36](#e36) | `GET /api/v1/migration-runs/{id}/reconciliation` | DBA／移轉驗收 | TC-05-05；T29 |
| [E37](#e37) | `PUT /api/v1/menu-items/{id}` | 選配：菜單維護 | TC-06-01；T33 |
| [E38](#e38) | `POST /api/v1/orders` | 選配：POS | TC-06-02；T34 |
| [E39](#e39) | `POST /api/v1/orders/{id}/fulfillments` | 選配：廚房／取餐 | TC-06-03；T35 |
| [E40](#e40) | `POST /api/v1/admin-users` | 帳號管理者 | TC-04-05；T07 |
| [E41](#e41) | `PATCH /api/v1/admin-users/{id}/status` | 帳號管理者 | TC-04-05；T07 |
| [E42](#e42) | `POST /api/v1/subsidy-rules/{id}/publish` | 餐補發布者 | TC-04-04；T12、T20 |


## 逐項請求與回應

<a id="e01"></a>
### E01 `GET /api/v1/employees`

- 角色／服務：HR／餐務查詢。
- 請求：Keyword,DepartmentId,EmploymentStatus,Page,PageSize。
- 回應 data：Items,Total,Version。
- 狀態：一期設計草案，待實作。

<a id="e02"></a>
### E02 `POST /api/v1/employees/import-jobs`

- 角色／服務：HR 維護。
- 請求：OperationId,SourceBatchId,SourceVersion,Rows 或核准檔案參照。
- 回應 data：JobId,Status,ValidationErrors。
- 狀態：一期設計草案，待實作。

<a id="e03"></a>
### E03 `POST /api/v1/card-assignments`

- 角色／服務：卡務。
- 請求：OperationId,PersonId,CardCode,ValidFrom,ValidTo。
- 回應 data：AssignmentId,RowVersion,SyncJobIds。
- 狀態：一期設計草案，待實作。

<a id="e04"></a>
### E04 `POST /api/v1/card-assignments/{id}/revoke`

- 角色／服務：卡務。
- 請求：OperationId,ExpectedVersion,Reason,EffectiveAt。
- 回應 data：AssignmentId,RevokedAt,SyncJobIds。
- 狀態：一期設計草案，待實作。

<a id="e05"></a>
### E05 `POST /api/v1/temporary-card-loans`

- 角色／服務：卡務。
- 請求：OperationId,PersonId,CardCode,ValidFrom,ValidTo,Reason。
- 回應 data：LoanId,RowVersion,SyncJobIds。
- 狀態：一期設計草案，待實作。

<a id="e06"></a>
### E06 `POST /api/v1/temporary-card-loans/{id}/return`

- 角色／服務：卡務。
- 請求：OperationId,ExpectedVersion,Reason,EffectiveAt。
- 回應 data：LoanId,ReturnedAt,SyncJobIds。
- 狀態：一期設計草案，待實作。

<a id="e07"></a>
### E07 `PUT /api/v1/subsidy-eligibilities/{id}`

- 角色／服務：餐務設定。
- 請求：ExpectedVersion,PersonId,EligibilityType,ValidFrom,ValidTo。
- 回應 data：Id,RowVersion。
- 狀態：一期設計草案，待實作。

<a id="e08"></a>
### E08 `PUT /api/v1/meal-periods/{id}`

- 角色／服務：餐務設定。
- 請求：ExpectedVersion,Name,StartTime,EndTime,BusinessDatePolicy,EffectiveFrom。
- 回應 data：Id,Version,IsCrossDay。
- 狀態：一期設計草案，待實作。

<a id="e09"></a>
### E09 `PUT /api/v1/lanes/{id}/bindings`

- 角色／服務：設備設定。
- 請求：ExpectedVersion,ReaderIds,TerminalIds,EffectiveFrom。
- 回應 data：LaneId,BindingVersion。
- 狀態：一期設計草案，待實作。

<a id="e10"></a>
### E10 `GET /api/v1/devices/status`

- 角色／服務：設備查詢。
- 請求：SiteId?,LaneId?,HealthState?。
- 回應 data：Items,LastSeenAt,Backlog,ParserErrors。
- 狀態：一期設計草案，待實作。

<a id="e11"></a>
### E11 `POST /api/v1/gateway/swipe-events/batch`

- 角色／服務：Gateway 裝置。
- 請求：BatchId,Events[SourceEventKey,ReaderId,CardCode,RawDataRef,DeviceTime,ReceivedAt,ParserVersion]。
- 回應 data：Accepted,Duplicates,Rejected[{SourceEventKey,Code}],AckCursor?。
- 狀態：一期設計草案，待實作。

<a id="e12"></a>
### E12 `POST /api/v1/devices/{id}/card-sync-jobs`

- 角色／服務：卡務／授權工作服務。
- 請求：OperationId,Mode,SourceVersion,CardChanges,Reason。
- 回應 data：JobId,Status。
- 狀態：一期設計草案，待實作。

<a id="e13"></a>
### E13 `GET /api/v1/devices/{id}/card-sync-jobs/{jobId}`

- 角色／服務：卡務／設備查詢。
- 請求：路徑 ID。
- 回應 data：Status,AttemptCount,CentralEffectiveAt,DeviceAcknowledgedAt,LastError。
- 狀態：一期設計草案，待實作。

<a id="e14"></a>
### E14 `POST /api/v1/pos/swipe-events/claim`

- 角色／服務：授權 POS。
- 請求：OperationId,EventId?；終端與餐道由認證身分推得。
- 回應 data：ClaimId,EventId,ExpiresAt,PersonDisplay,AssignmentVersion。
- 狀態：一期設計草案，待實作。

<a id="e15"></a>
### E15 `POST /api/v1/pos/swipe-events/{id}/release`

- 角色／服務：原領取 POS。
- 請求：OperationId,ClaimId,Reason。
- 回應 data：State,ReleasedAt。
- 狀態：一期設計草案，待實作。

<a id="e16"></a>
### E16 `POST /api/v1/pos/quotes`

- 角色／服務：原領取 POS。
- 請求：OperationId,ClaimId,TotalAmountMinor,Currency。
- 回應 data：QuoteId,ExpiresAt,RuleVersion,TotalAmountMinor,Breakdown,BusinessDate。
- 狀態：一期設計草案，待實作。

<a id="e17"></a>
### E17 `POST /api/v1/pos/transactions`

- 角色／服務：原領取 POS。
- 請求：ClientTransactionId,ClaimId,QuoteId。
- 回應 data：TransactionId,Status,CommittedAt,BusinessDate,TotalAmountMinor,Breakdown。
- 狀態：一期設計草案，待實作。

<a id="e18"></a>
### E18 `GET /api/v1/pos/transactions/by-client-id/{clientId}`

- 角色／服務：原 POS／授權主管。
- 請求：固定 ClientTransactionId。
- 回應 data：TransactionId,Status,Totals；查無明確 NOT_FOUND。
- 狀態：一期設計草案，待實作。

<a id="e19"></a>
### E19 `POST /api/v1/transactions/{id}/reversals`

- 角色／服務：沖正授權主管。
- 請求：OperationId,ExpectedVersion,Reason。
- 回應 data：ReversalId,OriginalTransactionId,ReversedAmountMinor,SettlementAdjustmentId?。
- 狀態：一期設計草案，待實作。

<a id="e20"></a>
### E20 `POST /api/v1/transactions/{id}/replacement-drafts`

- 角色／服務：更正授權主管。
- 請求：OperationId,Reason,OriginalVersion；重新驗證方式依 Q07。
- 回應 data：DraftId,RequiresRescan,RequiresNewQuote。
- 狀態：一期設計草案，待實作。

<a id="e21"></a>
### E21 `GET /api/v1/pos/operating-status`

- 角色／服務：授權 POS。
- 請求：終端身分。
- 回應 data：Mode,CanAuthorizeNewTransaction,PolicyVersion,ServerTime。
- 狀態：一期設計草案，待實作。

<a id="e22"></a>
### E22 `GET /api/v1/transactions`

- 角色／服務：餐務查詢。
- 請求：PersonId?,BusinessDateFrom,To,LaneId?,Status?,Page,PageSize。
- 回應 data：Items,Total,Summary。
- 狀態：一期設計草案，待實作。

<a id="e23"></a>
### E23 `POST /api/v1/manual-adjustments`

- 角色／服務：補登授權者。
- 請求：OperationId,PersonId,OccurredAt,LaneId,AmountMinor,Reason,EvidenceRefs。
- 回應 data：AdjustmentId,TransactionId?,ApprovalStatus。
- 狀態：一期設計草案，待實作。

<a id="e24"></a>
### E24 `GET /api/v1/exceptions`

- 角色／服務：餐務／維運查詢。
- 請求：Type?,State?,From,To,Page,PageSize。
- 回應 data：Items,Total。
- 狀態：一期設計草案，待實作。

<a id="e25"></a>
### E25 `POST /api/v1/exceptions/{id}/resolutions`

- 角色／服務：異常處理者。
- 請求：OperationId,ExpectedVersion,ResolutionType,Reason,EvidenceRefs。
- 回應 data：ResolutionId,State,LinkedTransactionIds。
- 狀態：一期設計草案，待實作。

<a id="e26"></a>
### E26 `PUT /api/v1/subsidy-rules/{id}`

- 角色／服務：餐補設定者。
- 請求：ExpectedVersion,RuleDraft,EffectiveFrom,ApprovedExampleRefs。
- 回應 data：DraftVersion,ValidationErrors。
- 狀態：一期設計草案，待實作。

<a id="e27"></a>
### E27 `PUT /api/v1/roles/{id}/permissions`

- 角色／服務：權限管理者。
- 請求：ExpectedVersion,Actions,SiteScopes,LaneScopes,Reason。
- 回應 data：RoleId,Version。
- 狀態：一期設計草案，待實作。

<a id="e28"></a>
### E28 `GET /api/v1/audit-logs`

- 角色／服務：稽核查詢。
- 請求：ActorId?,Action?,EntityId?,From,To,Page,PageSize。
- 回應 data：Items,Total。
- 狀態：一期設計草案，待實作。

<a id="e29"></a>
### E29 `POST /api/v1/reports/employee-costs/export-jobs`

- 角色／服務：財務／匯出權限。
- 請求：OperationId,From,To,PersonFilter,FormatVersion。
- 回應 data：JobId,Status,FileRef?；下載另驗權限。
- 狀態：一期設計草案，待實作。

<a id="e30"></a>
### E30 `POST /api/v1/settlement-batches`

- 角色／服務：結算建立者。
- 請求：OperationId,VendorId,From,To,FormatVersion。
- 回應 data：BatchId,Status,Totals,Exceptions。
- 狀態：一期設計草案，待實作。

<a id="e31"></a>
### E31 `POST /api/v1/settlement-batches/{id}/confirm`

- 角色／服務：結算確認者。
- 請求：OperationId,ExpectedVersion,ReconciliationRef,Reason。
- 回應 data：BatchId,ConfirmedAt,SnapshotTotals。
- 狀態：一期設計草案，待實作。

<a id="e32"></a>
### E32 `GET /api/v1/reports/meal-counts`

- 角色／服務：餐務統計。
- 請求：From,To,Grouping,MetricVersion。
- 回應 data：Rows,Totals,Definitions。
- 狀態：一期設計草案，待實作。

<a id="e33"></a>
### E33 `POST /api/v1/integrations/hr-sync-jobs`

- 角色／服務：HR／整合服務。
- 請求：OperationId,SourceId,SourceBatchId,Cursor,SourceVersion。
- 回應 data：JobId,Status。
- 狀態：一期設計草案，待實作。

<a id="e34"></a>
### E34 `GET /api/v1/integrations/jobs/{id}`

- 角色／服務：整合查詢。
- 請求：路徑 ID。
- 回應 data：Status,Counts,Errors,Checkpoint。
- 狀態：一期設計草案，待實作。

<a id="e35"></a>
### E35 `POST /api/v1/migration-runs`

- 角色／服務：限移轉環境／DBA。
- 請求：OperationId,SourceSnapshotId,MappingVersion,DryRun。
- 回應 data：RunId,Status,ValidationErrors。
- 狀態：一期設計草案，待實作。

<a id="e36"></a>
### E36 `GET /api/v1/migration-runs/{id}/reconciliation`

- 角色／服務：DBA／移轉驗收。
- 請求：路徑 ID。
- 回應 data：Counts,AmountTotals,Rejects,Differences。
- 狀態：一期設計草案，待實作。

<a id="e37"></a>
### E37 `PUT /api/v1/menu-items/{id}`

- 角色／服務：選配：菜單維護。
- 請求：ExpectedVersion,Name,PriceMinor,AvailableFrom,To,Status。
- 回應 data：ItemId,PriceVersion。
- 狀態：選配；Q01 納入後才實作。

<a id="e38"></a>
### E38 `POST /api/v1/orders`

- 角色／服務：選配：POS。
- 請求：ClientOrderId,Items,QuoteRef,OperationId。
- 回應 data：OrderId,Status,StockReservationIds。
- 狀態：選配；Q01 納入後才實作。

<a id="e39"></a>
### E39 `POST /api/v1/orders/{id}/fulfillments`

- 角色／服務：選配：廚房／取餐。
- 請求：OperationId,ExpectedVersion,Action,PickupReference。
- 回應 data：OrderId,FulfillmentStatus,OccurredAt。
- 狀態：選配；Q01 納入後才實作。

<a id="e40"></a>
### E40 `POST /api/v1/admin-users`

- 角色／服務：帳號管理者。
- 請求：OperationId,IdentitySource,ExternalSubject?,DisplayName,Roles,Scopes。
- 回應 data：UserId,Status；密碼透過另外核准的安全流程設定。
- 狀態：一期設計草案，待實作。

<a id="e41"></a>
### E41 `PATCH /api/v1/admin-users/{id}/status`

- 角色／服務：帳號管理者。
- 請求：OperationId,ExpectedVersion,Status,Reason。
- 回應 data：UserId,Status,SessionRevocationState。
- 狀態：一期設計草案，待實作。

<a id="e42"></a>
### E42 `POST /api/v1/subsidy-rules/{id}/publish`

- 角色／服務：餐補發布者。
- 請求：OperationId,ExpectedDraftVersion,EffectiveFrom,ApprovalReference。
- 回應 data：PublishedVersion,EffectiveFrom。
- 狀態：一期設計草案，待實作。


## POS 提交範例（合成資料，非可呼叫請求）

```json
{
  "ClientTransactionId": "11111111-1111-4111-8111-111111111111",
  "ClaimId": "22222222-2222-4222-8222-222222222222",
  "QuoteId": "33333333-3333-4333-8333-333333333333"
}
```

終端身分從認證取得，提交不接受任意 PersonId、RuleVersion 或自行計算的分攤。服務端依 Quote、Claim、當前資格及規則有效性驗證；若需重報價，先讓操作人重新確認。

範例成功結果：

```json
{
  "success": true,
  "code": "OK",
  "data": {
    "TransactionId": "44444444-4444-4444-8444-444444444444",
    "Status": "COMMITTED",
    "Currency": "TWD",
    "TotalAmountMinor": 8000,
    "Breakdown": [
      {"Payer": "COMPANY", "AmountMinor": 5000},
      {"Payer": "DL", "AmountMinor": 0},
      {"Payer": "EMPLOYEE", "AmountMinor": 3000}
    ]
  },
  "traceId": "synthetic-trace-001"
}
```

此 80/50/0/30 僅供契約與金額守恆測試，不是客戶補助規則。COMMITTED 表示一期內部記帳已提交，不表示未納入規格的外部收款完成。

## 錯誤與重試

| HTTP／業務碼提案 | 情境 | 客戶端動作 |
|---|---|---|
| 400 INVALID_REQUEST | 欄位、型態、金額或時間格式錯誤 | 修正輸入；同一操作內容未變才沿用原去重鍵 |
| 401 UNAUTHENTICATED | 使用者或裝置未認證 | 恢復合法身分；不重建交易 |
| 403 OUT_OF_SCOPE | 跨餐道、跨廠區或無操作權 | 停止操作並提示，不改成另一終端重送 |
| 409 IDEMPOTENCY_CONFLICT | 相同交易 ID 但請求不同 | 查原交易並人工判斷，不覆寫原請求 |
| 409 VERSION_CONFLICT | 資料、規則或 Claim 版本不符 | 重新載入／報價；原已提交交易仍回原結果 |
| 409 IN_PROGRESS | 原交易仍處理中 | 保留 ID，退避查單 |
| 410 CLAIM_EXPIRED / QUOTE_EXPIRED | 新提交使用過期領取或報價 | 重新確認；已完成的同 ID 重試先回原結果 |
| 422 CARD_INVALID / INELIGIBLE / LIMIT_EXCEEDED | 卡片、資格或權益限制 | 顯示具體原因，不當網路錯誤重送 |
| 404 TRANSACTION_NOT_FOUND | 在授權範圍內尚無該交易 | 按查單政策確認是否仍在途；不立即換 ID 另扣 |
| 503 SERVICE_UNAVAILABLE | 尚未受理或無法確定結果 | 標示結果待確認，以原 ID 查單，依 Q09 降級 |


異常訊息不得包含密碼、金鑰、完整連線字串或其他人員資料。網路中斷本身不能證明業務失敗。第三方接口若不能去重，必須以其查單機制核對，不承諾僅靠本服務達成跨系統一次作用。

