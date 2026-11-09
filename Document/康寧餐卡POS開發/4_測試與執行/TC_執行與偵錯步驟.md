# TC 執行與偵錯步驟

版本 v1.2｜2026-11-08。本機可執行 .NET 10 API／Vue 3、合成流程／後台及原始取樣／重播 CLI；DB、正式協定 Gateway、身分與業務交易尚未接入。

## 1. 本機啟動

需求：.NET 10 SDK、Node 24.12 以上的 24.x 版本、npm。從儲存庫根目錄開第一個 PowerShell：

```powershell
dotnet restore SourceCode/Api/TC.slnx
dotnet run --project SourceCode/Api/TC_API --launch-profile http
```

另一個 PowerShell：

```powershell
Set-Location SourceCode/Web
npm.cmd ci
npm.cmd run dev
```

API 為 `http://localhost:5181`；Vue 為 `http://127.0.0.1:5180/#/pos`，`/#/system` 可確認真實 API 連線。`/health/live` 僅判斷程序存活，不能當成 DB／刷卡／計費驗證。Swagger 僅 Development 的 `/swagger` 提供。

執行 npm ci 或更新套件前先停止 Vite，避免 Windows 原生模組被鎖定。改環境可複製 `SourceCode/Web/.env.example` 為 `.env.local`；`VITE_API_BASE_URL` 為公開設定，不填金鑰。Vite 將 `/api`、`/health` 代理到 `TC_API_PROXY_TARGET`；`vite preview` 不代理 API。

## 2. 建置與基礎測試

```powershell
dotnet build SourceCode/Api/TC.slnx
dotnet test SourceCode/Api/TC.slnx
Set-Location SourceCode/Web
npm.cmd run lint
npm.cmd test
npm.cmd run build
```

本次通過 API 16、取樣工具 6、Vue 25 項測試及 lint／build；限制見 [前期核對紀錄](../../AI區/前期規劃核對與開發安排.md)。不回填 A01–A39 為通過。靜態版面預覽可用 `/#/pos?preview=ready`，原始 HTML 入口見 [靜態畫面原型](../3_設計與契約/靜態畫面原型/README.md)；正式產物停用示範切換。

### 合成 API 流程與後台

Development 的 `appsettings.Development.json` 已設定 `Development.EnableSimulation=true`。以本機瀏覽器開啟：

1. `http://127.0.0.1:5180/#/development`，選合成卡、模擬刷卡、確認總額。
2. 畫面回傳 `SIMULATED` 測試紀錄後，目前人員清空；可測下一位或撤銷卡拒絕。
3. 開 `/#/admin/transactions` 查看同一 API 程序的紀錄、重新整理或匯出測試 CSV。匯出未計分攤，不能交作財務結算。
4. 回應中斷時顯示結果待確認，保留原 UUID；先查原交易，明確按「查詢後重送原請求」也沿用相同內容。sessionStorage 只存 UUID，不保存姓名、卡號或金額。

模擬 API 需 `X-TC-Simulation: 1`，具體請求欄位見 [API 契約](../3_設計與契約/TC_API契約.md#development-simulation)。只有 Development、旗標開啟、本機來源及本機 Origin 可用；Production 不映射，正式 Controller 仍預設拒絕存取。

模擬器限單一測試終端；程序重啟清空資料，無正式持久恢復。離頁會嘗試釋放未提交 Claim，失敗仍有 5 分鐘到期保護；已送出則保留原 ID、不釋放提交。Quote 2 分鐘失效，都是測試值。若重啟 API 導致舊測試 ID 查無資料，先核對已重啟，再在開發瀏覽器清除 `tc.simulation.pending` 或新開獨立測試工作階段；此作法只供丟棄合成資料，不能套用正式交易。

API 與 Vite 啟動後，可從根目錄跑完整瀏覽器測試（需要已安裝 Chrome 與 Node 24，不需額外 npm 套件）：

```powershell
node Tests/Browser/simulation-smoke.mjs
```

腳本使用獨立暫存 Chrome profile，實際按鈕操作及下載 CSV；會新增合成紀錄，截圖／CSV 路徑印於結果，不操作原本開啟的瀏覽器。可用 `TC_CHROME_PATH`、`TC_WEB_URL` 覆寫測試環境；不以此驗證正式帳務。

### RFID 原始取樣／離線重播

以下從儲存庫根目錄執行，兩個命令都不連實體設備：

```powershell
dotnet run --project SourceCode/Gateway/TC_RfidCapture -- --help
dotnet run --project SourceCode/Gateway/TC_RfidCapture -- --replay Tests/Fixtures/raw-capture.synthetic.jsonl
```

預期重播輸出 `REPLAY_OK chunks=2 bytes=11`，只證明保存片段完整，不證明 RFID 解析成功。毀損／空取樣回非零 exit code。

實機階段先查證當前設備 IP／Port；下列為**尚不可直接執行的填值範例**，不使用舊端點，也不掃描內網：

```powershell
dotnet run --project SourceCode/Gateway/TC_RfidCapture -- --host <目前確認的IP> --port <目前確認的Port> --seconds 30 --output artifacts/captures/<新的取樣名稱>.jsonl
```

工具限 IP literal、1–300 秒與 16 MiB，輸出檔必須不存在；只連線接收、不送初始化／ACK／清除命令、不寫 DB。每行保存接收片段及 SHA-256，TCP Read 片段並非設備 frame。沒有 bytes 回失敗；有 bytes 也只代表收到資料，仍須測試卡人工對照。實際取樣可能含個資，保存於受控且 Git 忽略的路徑。

## 3. 待補資訊

| 項目 | 目前狀態 | 後續工作 |
|---|---|---|
| API／Web | 本機骨架可執行 | 正式 HTTPS、託管、CORS 與部署：T04/Q11 |
| 身分／餐道 | PendingIdentityHandler 預設拒絕受保護端點 | 身分來源、後端餐道範圍與權限：T07/Q11 |
| Gateway | 已建原始取樣／重播 CLI，沒有正式協定服務 | 當前端點、協定、SDK、部署、持久事件／補傳：T02/T14–T16 |
| DB | 未還原或連線；無 Context／Migration | 隔離盤點與資料模型：T03/T06 |
| 業務交易 | E01–E42 尚未實作 | 依工作項目與 Q 決策實作 |
| 日誌／告警 | Console 錯誤與 traceId | 留存、敏感資料遮罩、告警：T30/Q12 |

DB 唯讀盤點見[TC_舊系統唯讀盤點.sql](../3_設計與契約/SQL/TC_舊系統唯讀盤點.sql)。骨架啟動不需要也不會還原 DB 或連卡機。

## 4. 問題定位

| 現象 | 先查 |
|---|---|
| Vue 顯示 API 未連線 | API 5181 是否啟動、代理設定、服務 Console 與 traceId |
| 啟動提示埠已使用 | 查明既有服務；修改本案埠與 proxy，不任意停止其他專案 |
| API 回 401 | 目前沒有正式登入；預設拒絕受保護端點，不加入繞過旗標 |
| 設定無法保存 | localStorage 限制；表單保留舊設定並顯示錯誤 |
| POS 一直待刷卡 | 正式產物預設如此；目前沒有讀卡機事件來源 |
| 示範確認完成但無交易 | 預期行為；沒有正式提交或 DB 寫入，不應宣告記帳成功 |

未來正式交易回應逾時先以原 ClientTransactionId 查單，不能由斷線推定未入帳。設備、DB 及完整上線操作於對應工作有實作與核准環境後另補。
