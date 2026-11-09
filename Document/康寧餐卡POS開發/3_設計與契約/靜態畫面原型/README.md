# POS 靜態畫面原型

2026-11-08 從專案根目錄搬入規劃文件，六個原檔的 SHA-256 與搬移前相同。HTML、共用 CSS 與 JS 保持同層，雙擊 HTML 即可檢視；也可先開啟 [畫面索引](index.html)。

| 畫面 | 實際狀態 | 用途 |
|---|---|---|
| [pos_idle.html](pos_idle.html) | 待刷卡 | 空白身分及停用送出 |
| [pos_reading.html](pos_reading.html) | 讀卡中 | 等待辨識 |
| [pos_success.html](pos_success.html) | **ready：辨識後待確認** | 檔名沿用舊名，並非記帳成功；可示範確認金額 |
| [pos_error.html](pos_error.html) | 讀卡失敗 | 錯誤提示及停用送出 |
| [pos.css](pos.css)／[pos.js](pos.js) | 共用樣式及示範互動 | 設定只存瀏覽器，未串接設備或交易 API |

這些檔案是設計參考，畫面資料與確認提示不代表正式帳務。實際 Vue 開發位於 [pos-view.vue](../../../../SourceCode/Web/src/views/pos/pos-view.vue)；透過 API 的合成流程則在開發模式的 `/#/development`，兩者用途見 [畫面與權限契約](../TC_畫面與權限契約.md)。
