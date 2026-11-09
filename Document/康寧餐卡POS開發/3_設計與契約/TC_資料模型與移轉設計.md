# TC 資料模型與移轉設計

版本 v1.0｜邏輯模型草案，未建表。T03 核對實際來源、T06 定案實體與 DB 腳本。中文註解不是業務規則或實際 FK 的充分證據。

## 1. 邏輯實體與一致性

| 實體群 | 必要資料 | 唯一性／歷史原則 |
|---|---|---|
| Person / Department / Workplace | 來源系統、來源鍵、員編、姓名、類別、在職、生效版本 | 來源鍵唯一；編號與姓名不可截斷；先確認權威來源 |
| CardCredential / CardAssignment | 原始卡碼、正規值、編碼版本、PersonId、有效起迄、撤銷與卡別 | 同卡有效指派不可重疊；歷史交易保存當時指派 ID |
| Eligibility / RuleVersion | 資格期間、適用人員、金額、優先次序、發布與生效時間 | 已發布版本不可原地改寫；規則公式由 Q05/Q06 決定 |
| MealPeriodVersion | 起迄、廠區時區、跨日與營業日策略 | 避免重疊；起訖相同不自行沿用 M10 的 24 小時定義 |
| Device / LaneBinding | 型號韌體、協定、ReaderId、TerminalId、SiteId、LaneId、生效版本 | 設備與終端對應不可歧義；舊交易保存原綁定 |
| RawReceipt / SwipeEvent | 接收片段或持久位置、frame、設備序號、事件鍵、原始值、時間與解析版本 | 原始片段不等同事件；來源鍵穩定才能可靠去重 |
| Claim / Quote | EventId、TerminalId、租約、身分與規則版本、金額、到期 | 領取原子化；過期不影響既有成功交易的原結果查詢 |
| SaleTransaction / Allocation | ClientTransactionId、請求雜湊、Claim/Quote、Person/Assignment、營業日、金額快照 | UNIQUE(SiteId,ClientTransactionId)；另驗證終端及內容一致 |
| BenefitBucket / EntitlementUse | 員工、權益範圍、可用次數／額度、已用量、TransactionId | 依 Q06 決定權益桶；同交易與同權益作用唯一，併發原子占用 |
| Reversal / ManualAdjustment | 原交易、獨立操作 ID、原因、證據、反向分攤及審核 | 不刪原帳；重複操作回原結果；已結算另產調整 |
| Inbox / Outbox / SyncJob | 穩定鍵、來源版本、內容、狀態、確認點、次數、下次重試及錯誤 | 主檔／交易與待送資料同一 SQL 交易保存 |
| SettlementBatch / SettlementItem | 廠商、期間、口徑、交易/調整引用、快照、確認與版本 | 同一計費項不可重複結算；已確認批次唯讀 |
| ExceptionCase / AuditLog | 來源、類型、實體 ID、操作者、原因、前後版本與處理狀態 | 稽核不可被一般維護功能任意覆寫 |
| MigrationRun / MappingVersion | 來源快照、映射、批次、拒收、筆數與金額差異 | 同來源與版本重跑可辨識；不以刪除正式資料完成重跑 |


以上是邏輯責任，不要求每項各建一張表。T06 依查詢、交易與部署決定合表或拆表。BenefitBucket 的唯一鍵不應只用卡號，也不應因規則版本改變就無條件給同餐新額度；此範圍由 Q06 核准。

## 2. 型態與共通欄位

- 新系統識別碼與業務編號分開；原卡碼、員編使用字串並保存來源長度，不先限為舊 POS 10 字元。
- 時間以 datetimeoffset 或經確認的 UTC 欄位保存，另有設備原值、廠區時區與 BusinessDate。來源字符串解析失敗列拒收。
- 金額以 Currency + AmountMinor 整數表示，TWD 100 minor = 1 元；不使用二進位浮點計費。設定上限，明細與總額守恆。
- 可變資料具 RowVersion/ExpectedVersion；歷史快照與稽核不可跟隨主檔自動重算。
- 視實際情況加唯一索引、FK、狀態/金額 CHECK，以及 PersonId+BusinessDate、LaneId+OccurredAt、待工作狀態等查詢索引；實際執行計畫由 T06/T31 檢核。

## 3. 舊表對應與差異

| 來源 | 建議用途 | 必須驗證 |
|---|---|---|
| Dining.employee / depart / jobplace；POS.employ | Person 與組織 | 權威來源、員編 13/10、姓名 50/10、部門 10/2 的差異 |
| tcardno / tempcardno / tempcardno_set / employ.cardnu | CardAssignment 與臨時借還 | 卡碼 13/10、前導零、有效日 8/10 字串與日期型態、掛失語意 |
| subsidy_period / sysset / time_recording_set / employ.clsno* | Eligibility 與 RuleVersion | 公司/DL/自付語意、矩陣優先次序、生效期間 |
| time_recording / saloon_records | 歷史消費／原始事件參考 | 兩邊是否同筆、跨日 rdate/ndate/carddate、datasource 與取消關聯 |
| time_recording_cancel / cancel_sno | Reversal 參考 | 取消連回哪個來源、金額與補助如何回補 |
| lcc / time_recording_cardno | 設備命令／同步工作參考 | lcc 可能含命令佇列；不是看到名稱就當一般 log |
| m_* | 用途待驗，暫不刪除 | 文件雖稱 Mirror，欄位不一定與主表相同；需查讀寫與更新機制 |
| pbcat* / app_pbd | 舊 PB 工具與版本資訊 | 不直接轉成新業務表，也不能未驗就刪原庫 |


## 4. 移轉步驟

1. T03 取得核准備份與隔離測試庫，驗證備份可還原、版本及資料完整性；不將原 MDF 附加到正式庫。
2. 使用 [唯讀盤點 SQL](SQL/TC_舊系統唯讀盤點.sql)查實際型態、索引與約束。此腳本不查人員卡號或密碼值，也不還原 DB。
3. 建立來源快照與 MappingVersion，輸出重複鍵、空值、孤兒、日期錯誤、超長與金額異常。
4. 先轉組織、員工、卡片歷程、餐別資格，再試轉歷史消費與取消。無法證明對應的資料列入差異，不猜測。
5. 核對來源／目標筆數、有效指派、各營業日/餐道/人員類別金額、取消、分攤守恆及報表。
6. 重跑同快照、映射與批次，證明不重複。保留拒收原因、人工修正與重跑紀錄。
7. T32 依截止點與來源游標執行最後增量及對帳，核准後才切單一計費權威。

本版不提供未經實際 schema 驗證的建庫 DDL、DROP 或原資料清理腳本。正式 DB 變更由 T06/T29 準備並驗證後交審。

