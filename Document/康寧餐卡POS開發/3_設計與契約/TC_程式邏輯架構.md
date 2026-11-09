# TC 程式邏輯架構

版本 v1.1｜2026-11-07。T04 已建立 API／Vue 底層；以下業務分層仍為目標架構，T06、Gateway 與正式部署待確認。

## 1. 專案分層

| 邏輯專案 | 責任 | 不應承擔 |
|---|---|---|
| Api | HTTP、認證授權、輸入檢查、DI、統一錯誤與工作查詢 | 不在 Controller 重寫餐補公式 |
| Application | 卡片指派、資格報價、交易提交、補登沖正、同步與結算用例 | 不依賴 POS 的畫面狀態判斷金額 |
| Domain | 餐別、營業日、金額、權益、狀態與版本規則 | 不直接操作 HTTP 或設備 Socket |
| Infrastructure | SQL、交易、Outbox/Inbox、工作排程、身分源及外部轉接 | 不猜測未確認的設備封包 |
| Gateway | DeviceSession、協定解析、持久佇列、確認點與設備命令 | 不自行產生第二份權威計費 |
| Web／POS | 畫面、確認、查單、可見權限與錯誤處理 | 不直接寫 DB 或決定補助額度 |
| Tests | 規則、SQL 併發、API、重播及故障案例 | 不以模擬通過代替實體設備驗收 |


T04 已建立 `SourceCode/Api/TC.slnx`、`TC_API`、`CommonLibrary`（Application／Domain／Infrastructure）、`SourceCode/Web` 與 `Tests/TC_API.Tests`。2026-11-08 加入 `SourceCode/Gateway/TC_RfidCapture` 與 `Tests/TC_RfidCapture.Tests`，同屬 solution；這是原始 TCP 取樣／JSONL 重播 CLI，尚非正式分框、持久佇列或 Windows 背景服務。啟動見[執行文件](../4_測試與執行/TC_執行與偵錯步驟.md)，工程選擇見[建置紀錄](../../AI區/專案底層建置紀錄.md)。

目前唯讀系統資訊可走完 Controller → Application → DTO；沒有 SQL、正式帳務或設備實作。API 使用 `/api/v1`／camelCase，與 MHC 的 `/api/back`／PascalCase 保持不同。正式身分待 T07，受保護端點由 PendingIdentityHandler 暫時拒絕。

另有 Development 專用 `SimulationRoutes` → `Application/Simulation/SimulationWorkflow` → 嵌入合成資料，僅以程序記憶體與 lock 驗證流程；不能把此 lock 當作 T06/T20 SQL 去重或權益併發。Vue `useSimulationPos` 使用獨立 wrapper，後台清單及 CSV 只讀此模擬資料，不接舊 DB。

## 2. 核心用例

| 用例／介面草案 | 輸入 | 輸出／副作用 | 驗證 |
|---|---|---|---|
| ICardAssignmentService | 原始卡碼、事件時間、來源系統 | 當時有效指派或具體拒絕原因 | A04/A05/A12/A19 |
| IMealPeriodResolver | 設備時間、廠區時區、設定版本 | MealPeriodId、BusinessDate | A07/A08 |
| IQuoteService | Claim、金額、資格與規則版本 | 可到期 Quote 與分攤快照 | A06/A20 |
| ITransactionService | 固定 ClientTransactionId、Quote、Claim | 原子保存交易、權益使用、去重及 Outbox | A21/A22/A23/A24 |
| IReversalService | 原交易、操作 ID、權限與理由 | 沖正、反向分攤與結算調整 | A25/A26 |
| IDeviceProtocolAdapter | 型號、韌體與位元組串流 | 有效 frame、來源事件與 ACK/游標 | A10–A15 |
| ICardSyncService | 卡片狀態版本、設備目標 | 工作、確認、重試及雙生效時間 | A15/A29 |
| ISettlementService | 區間、廠商、口徑版本 | 批次快照、確認與調整 | A30/A31/A32 |


## 3. 交易邊界

單一 SQL 交易包含：請求去重鍵＋請求雜湊、Claim/Quote 狀態、已提交消費、分攤、補助使用、事件作用狀態、Outbox。唯一約束及併發控制是正確性的一部分，不能只用先查後寫。

先查已存在交易 ID 的原結果，再判斷新請求的有效期；否則已成功的重試可能因 Quote 到期被錯誤拒絕。相同 ID 內容不同回衝突。費用不能在 Gateway 與 API 各算一次。

外部支付不參加本 SQL 原子範圍，需依 Q08 額外定義付款狀態、查單與補償，未確認前保持接口邊界。

## 4. 可靠通知與背景工作

先以資料庫 Outbox 與可重入的工作處理即可，不強制新增訊息平台。每個工作有狀態、嘗試次數、下次處理時間、最後錯誤與人工作業記錄；消費端亦去重。

通知只作提示，POS 重連後以持久事件／交易結果補取。Gateway 可以保存並重傳事件，但 ACK 的時點要依實際設備協定確認。多實例接收採設備領取/租約與來源穩定鍵，避免雙接收或斷線後的重複作用。

## 5. 安全與維運

裝置、操作人與資料範圍分開驗證。卡號是身分查找依據，卡片防偽與加解密主機依原廠契約；傳輸加密不能代替交易授權。

設定與金鑰由部署的機密方式提供，不寫在文件、Git 或測試資料。日誌以事件/交易 ID 為主，原始卡碼與照片的存取、遮罩、留存及清理依 Q12。設備 TCP 無原生加密時須交由客戶 IT 確認網段、ACL 與轉接邊界。

監控至少包含：連線與最後有效事件、解析失敗、游標／補傳積壓、儲存容量、交易未知數、同步失敗、結算帳差及服務重啟。無刷卡不等於設備故障。

