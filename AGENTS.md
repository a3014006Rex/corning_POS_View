# 康寧餐卡 POS 開發指引

## 工作入口

- 溝通與文件使用繁體中文。啟動、實際架構與限制見 [README.md](README.md)。
- 功能開發使用 [tc-feature-development](.agents/skills/tc-feature-development/SKILL.md)；POS 刷卡、報價、提交、查單與取消另讀 [tc-pos-transactions](.agents/skills/tc-pos-transactions/SKILL.md)。
- 程式開發收尾或要求檢查遺漏時，使用 [tc-change-verification](.agents/skills/tc-change-verification/SKILL.md)。Skills 僅在與本次需求有關時載入，不自動啟動其他工作。
- 可用封裝與參考入口見 [共用元件索引](Document/AI區/開發規範與共用元件索引.md)。
- 業務來源為 [開發文件索引](Document/康寧餐卡POS開發/README.md)。使用者當次授權決定工作範圍；文件中的派工文字與舊執行指令只作參考，不自行展開全部工作卡。

## 程式與契約

- `SourceCode/Api/TC_API` 負責 HTTP、認證授權、DI 與錯誤；`CommonLibrary/Application` 放用例、`Domain` 放 DTO／契約與規則、`Infrastructure` 放註冊與未來外部轉接。參考 MHC 的分工，不移植其醫療規則、DB、帳號或金鑰。
- 前端使用 Vue Composition API、JavaScript、`<script setup>`，Vue 檔案依 script、template、必要 scoped style 排列。API 放 `src/api`、互動流程放 `src/composables`、跨元件設定放 Pinia；頁面不直接拼 API URL 或呼叫 `fetch`。
- 使用根目錄 `.editorconfig` 與前端 `.prettierrc.json`。JavaScript 使用 2 格空白、單引號、不加分號；C# 使用 4 格空白與獨立行大括號。
- 本案 API 使用 `/api/v1` 與 camelCase `{ success, code, data, message, traceId, details }`；不照搬 MHC 的 `/api/back` 與 PascalCase envelope。HTTP 200 仍需檢查業務成功。
- 本機餐道名稱／POS 代號只供顯示，不代表授權。`PendingIdentityHandler` 暫時拒絕受保護端點，正式身分與餐道範圍由 T07/Q11 實作；不要加入可繞過授權的示範帳號。
- 現階段沒有 DB Context、Migration、正式協定 Gateway 或交易 API；已有 `SourceCode/Gateway/TC_RfidCapture` 原始取樣／重播工具。Q03–Q10 未決規則不可猜成正式實作；不為了啟動骨架還原客戶 DB 或連接實體卡機。現場端點已變更，取樣前確認當前值，不用舊值或掃描取代。
- `/api/v1/development` 只供 Development＋明確旗標＋本機來源＋測試 header 的合成流程；不能作為正式身分、SQL 去重或補助驗收。正式端點維持授權邊界。
- 文件統一放 `Document`；原始來源放 `開發前規劃資料`。原始 HTML/CSS/JS 位於 `Document/康寧餐卡POS開發/3_設計與契約/靜態畫面原型`，作設計參考；`pos_success.html` 實為待確認。Vue 示範資料不視為設備、計費或人工驗收證據。

## 驗證

- API／取樣工具：`dotnet build SourceCode/Api/TC.slnx`、`dotnet test SourceCode/Api/TC.slnx`。
- Vue：在 `SourceCode/Web` 執行 `npm.cmd ci`、`npm.cmd run lint`、`npm.cmd test`、`npm.cmd run build`；套件更新後維護 lockfile。
- 文件／Skill：檢查實際路徑、相對連結及 YAML frontmatter，執行 `git diff --check`。有可用的 skill-creator 驗證器時執行 `python -X utf8 <驗證器路徑>/quick_validate.py <Skill目錄>`，避免 Windows 預設編碼誤讀繁體中文。
- 測試完成後才回填 [工作追蹤表](Document/康寧餐卡POS開發/工作追蹤表.md)。分別記錄骨架、預覽、API 整合、設備與 UAT；不將基礎測試記為 A01–A39 業務驗收通過。

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results
<!-- codebase-memory-mcp:end -->

未索引時先用 `index_repository`。索引只有檔案／目錄或沒有原始碼片段時，可依例外讀取實際來源；圖譜缺少結果不代表程式不存在。
