---
name: tc-feature-development
description: 開發康寧餐卡 POS 的 Vue 頁面、共用元件與 ASP.NET Core API 時使用，沿用本專案分層與需求追溯。純盤點或只做審查時不啟用。
---

# TC 功能開發

先讀 [AGENTS.md](../../../AGENTS.md) 與 [共用元件索引](../../../Document/AI區/開發規範與共用元件索引.md) 的相關部分。相對連結以本檔解析，程式路徑以儲存庫根目錄解析。

## 選擇開發範圍

以使用者需求與 [功能工作追溯表](../../../Document/康寧餐卡POS開發/2_規劃與工作項目/TC_需求工作驗收追溯表.md) 找到涉及的 TC／T／E／A 編號。查看受影響的 Q 決策，區分已確認內容、可先做骨架或模擬的內容，以及必須等正式規格的內容。文件依賴是判斷依據，不是擅自擴大使用者任務或重複索取已授權工作的理由。

## 實作起點

- API 用 `SystemController` → `ISystemInfoService`／`SystemInfoService` → DTO 作分層範例；這是唯讀基礎服務，不是交易或 CRUD 的完整樣板。
- Vue 沿用 `api/http.js`、功能 wrapper、必要的 composable／Pinia。載入、錯誤、取消、逾期回應與重複送出按實際需求處理。
- POS 顯示參考 `pos-view.vue` 與 [靜態畫面原型](../../../Document/康寧餐卡POS開發/3_設計與契約/靜態畫面原型/README.md)。`usePosPreview` 僅供預覽，`useSimulationPos` 僅供開發 API 模擬，均不直接作為正式計費實作。
- `TerminalSettingsDialog` 只維護瀏覽器顯示設定；設備與終端授權必須來自後端。API URL 由部署設定管理。
- 新資料模型先依資料盤點與契約建立；不要複製 MHC DB Context、醫療角色、連線設定或套件全集。

新增端點時同步 DTO、前端 wrapper 與 API 契約。需要真正的 POS 交易時使用 [tc-pos-transactions](../tc-pos-transactions/SKILL.md)。完成後依 [tc-change-verification](../tc-change-verification/SKILL.md) 驗證並回填實際證據；只修改需求涉及的內容。
