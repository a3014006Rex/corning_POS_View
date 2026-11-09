# 合成原始片段

`raw-capture.synthetic.jsonl` 僅驗證保存／重播，兩段共 11 bytes：`00 FF 01 41 42`、`43 0A 7F 80 02 03`。它不是 RFID 廠商 frame、卡號、checksum 或真實擷取；分段也不代表設備訊息邊界。

每行的 `sha256` 是保存片段的完整性雜湊，不是設備協定 checksum。`schemaVersion=1`，`sequence` 從 1 連續增加，`receivedAt` 為合成 UTC 時間，`byteCount` 與 Base64 還原後長度一致。CLI 重播成功應輸出 `REPLAY_OK chunks=2 bytes=11`。

實機原始資料可能含卡號，應放受控且 Git 忽略的 `artifacts/captures`，不得直接加入本目錄。正式解析測試須等 T02 取得有效資料及人工對照後建立。
