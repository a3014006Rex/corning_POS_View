# 康寧餐卡 POS

API＋Vue 專案底層，參考 `mhc` 的 `SourceCode/Api`、`SourceCode/Web` 分層及共用 HTTP 封裝。現有新版 POS 已移為 Vue 預覽；原始四個 HTML 與 CSS／JS 統一收在 [規劃書的靜態畫面原型](Document/康寧餐卡POS開發/3_設計與契約/靜態畫面原型/README.md)。

目前可執行系統資訊 API、Vue POS 預覽、透過 API 的合成刷卡流程、管理後台測試紀錄／CSV，以及 RFID 原始取樣與重播 CLI。模擬功能僅限本機 Development，資料存程序記憶體。尚無正式登入、卡號解析、SQL 連線、資格分攤或正式記帳；系統資訊的交易、DB、設備能力仍為 `false`。

規劃核對結論為「可以先開發前期，後續規則尚待定案」，見 [核對與安排](Document/AI區/前期規劃核對與開發安排.md)。所有維護文件已合併到 [Document](Document/README.md)；`開發前規劃資料` 保留客戶來源檔。

## 啟動

環境：.NET 10 SDK、Node.js 24.12 以上的 24.x 版本、npm。套件版本以 csproj、package.json 及 package-lock.json 為準。根目錄 `global.json` 選用 .NET 10 正式 SDK；已以本機 SDK 10.0.201／Node 24.14.0 建置驗證。

第一個 PowerShell，從儲存庫根目錄啟動 API：

```powershell
dotnet restore SourceCode/Api/TC.slnx
dotnet run --project SourceCode/Api/TC_API --launch-profile http
```

第二個 PowerShell：

```powershell
Set-Location SourceCode/Web
npm.cmd ci
npm.cmd run dev
```

- Vue：<http://127.0.0.1:5180/#/pos>
- API 連線狀態：<http://127.0.0.1:5180/#/system>
- 合成刷卡流程（Development）：<http://127.0.0.1:5180/#/development>
- 後台測試紀錄：<http://127.0.0.1:5180/#/admin/transactions>
- API：<http://localhost:5181/api/v1/system/info>
- Swagger（僅 Development）：<http://localhost:5181/swagger>
- 存活檢查：<http://localhost:5181/health/live>

Vite 將 `/api`、`/health` 代理到本機 API，不需修改瀏覽器安全設定。可複製 `SourceCode/Web/.env.example` 為 `.env.local` 修改環境；`VITE_` 設定會公開到前端，不放機密。正式部署需提供 HTTPS 與 `/api` 同源反向代理，或設定正式 API URL 及明確 CORS origins；`vite preview` 只檢視產物，不代理 API。

POS 開發模式頁尾可切換待刷卡、讀卡中、待確認、失敗。也可用 `/#/pos?preview=ready`；建置正式產物後停用預覽切換，預設停在待刷卡。確認只改變示範畫面，不送出交易。示範完成後可按「下一位」清除上一人資料。

## 目錄與契約

```text
SourceCode/Api/TC.slnx
  TC_API/                    HTTP、授權邊界、錯誤、Swagger、DI
  CommonLibrary/
    Application/             用例與服務介面
    Domain/                  DTO、回應契約與未來業務規則
    Infrastructure/          DI 與未來 SQL／外部轉接
SourceCode/Web/src/
  api/                       共用 HTTP client 與功能 wrapper
  components/                共用元件
  composables/               可重用互動流程
  router/                    Hash 路由
  stores/                    Pinia 終端顯示設定
  views/                     POS 與系統連線頁
Tests/TC_API.Tests/           API Host 整合測試
SourceCode/Gateway/TC_RfidCapture/ 原始 TCP 取樣／JSONL 重播，不含設備解析
Tests/TC_RfidCapture.Tests/   保存、重播及 loopback TCP 測試
Tests/Fixtures/              合成原始片段，不是廠商協定
.agents/skills/               本專案 AI Skills
Document/AI區/               開發封裝索引與架構決策
```

採用 `/api/v1` 與 camelCase envelope，符合本案 API 契約草案；未沿用 MHC 的醫療角色、DB、`/api/back` 或 PascalCase envelope。`PendingIdentityHandler` 讓未標示公開的 Controller 預設回 401，待 T07/Q11 接上正式身分來源及餐道範圍，沒有可用的示範登入。

Vue API 路徑由部署環境決定；餐道／POS 設定僅存瀏覽器供顯示，不能代表服務端授權。舊原型的 `laneName`、`postCode` 可讀取，舊 `apiUrl` 不會控制網路請求。

## 驗證

```powershell
dotnet build SourceCode/Api/TC.slnx
dotnet test SourceCode/Api/TC.slnx
Set-Location SourceCode/Web
npm.cmd run lint
npm.cmd test
npm.cmd run build
```

本機通過 .NET 22 項（API 16、原始取樣 6）、Vue 25 項及 lint／build。包含重複提交、原 ID 查單、過期報價、新刷卡不得覆蓋、結果不明恢復與模擬功能環境隔離。這些不取代 A01–A39 業務／設備／UAT；正式部署、DB、協定解析與授權尚未驗證。

離線驗證取樣工具（不連實機）：

```powershell
dotnet run --project SourceCode/Gateway/TC_RfidCapture -- --help
dotnet run --project SourceCode/Gateway/TC_RfidCapture -- --replay Tests/Fixtures/raw-capture.synthetic.jsonl
```

實機取樣需另外指定**目前已確認**的 IP／Port、時限及新輸出檔；不使用舊資料的端點。操作與限制見 [執行步驟](Document/康寧餐卡POS開發/4_測試與執行/TC_執行與偵錯步驟.md)。

## AI Skills 與開發資料

本次確認原儲存庫沒有 `SKILL.md`。參考 MHC 的共用方式建立三個本案 Skills：

- [tc-feature-development](.agents/skills/tc-feature-development/SKILL.md)：Vue、API 與需求追溯。
- [tc-pos-transactions](.agents/skills/tc-pos-transactions/SKILL.md)：正式 POS 交易的領取、報價、查單與帳務邊界。
- [tc-change-verification](.agents/skills/tc-change-verification/SKILL.md)：變更複查與驗證證據。

入口為 [AGENTS.md](AGENTS.md)。Skills 隨儲存庫維護，未修改全域安裝；若目前工具尚未重新掃描，可直接讀取以上檔案。位置依 [OpenAI 專案 Skills 文件](https://developers.openai.com/api/reference/cli) 的 `.agents/skills/` 慣例。

規劃與進度見 [開發文件索引](Document/康寧餐卡POS開發/README.md)、[工作追蹤表](Document/康寧餐卡POS開發/工作追蹤表.md)；架構選擇與待定項見 [底層建置紀錄](Document/AI區/專案底層建置紀錄.md)。

本次已確認條件、暫定假設與外部待確認項見 [一期規劃確認紀錄](Document/AI區/規劃確認紀錄.md)。依使用者要求先開發前期，必要問題延後至對應階段；不等同正式 RA 簽認。
