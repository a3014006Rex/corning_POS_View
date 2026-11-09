-- =============================================
-- Corning_POS_TC 資料庫 Extended Properties 註解
-- 產生日期: 2026-04-27
-- 共 9 張資料表 (業務表 4 張 + PB系統表 5 張)
-- 執行方式: 在 SSMS 選取 Corning_POS_TC 資料庫後執行
-- =============================================
USE [Corning_POS_TC];
GO
-- ============================================================
-- 可重複執行 (Idempotent): 已存在則更新，不存在則新增
-- ============================================================
IF OBJECT_ID('tempdb..#uep') IS NOT NULL DROP PROCEDURE #uep;
GO
CREATE PROCEDURE #uep
    @name       NVARCHAR(128),
    @value      SQL_VARIANT,
    @level0type VARCHAR(128) = NULL, @level0name SYSNAME = NULL,
    @level1type VARCHAR(128) = NULL, @level1name SYSNAME = NULL,
    @level2type VARCHAR(128) = NULL, @level2name SYSNAME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF (SELECT COUNT(*) FROM fn_listextendedproperty(
            @name, @level0type, @level0name,
            @level1type, @level1name,
            @level2type, @level2name)) > 0
        EXEC sp_updateextendedproperty
            @name=@name, @value=@value,
            @level0type=@level0type, @level0name=@level0name,
            @level1type=@level1type, @level1name=@level1name,
            @level2type=@level2type, @level2name=@level2name;
    ELSE
        EXEC sp_addextendedproperty
            @name=@name, @value=@value,
            @level0type=@level0type, @level0name=@level0name,
            @level1type=@level1type, @level1name=@level1name,
            @level2type=@level2type, @level2name=@level2name;
END
GO


-- ============================================================
-- 業務資料表 — 共 4 張
-- ============================================================

-- ============ employ (POS 端員工資料) ============
EXEC #uep @name=N'MS_Description', @value=N'POS 刷卡機本地員工資料表 (含照片)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'empno';
EXEC #uep @name=N'MS_Description', @value=N'員工姓名', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'name';
EXEC #uep @name=N'MS_Description', @value=N'部門代號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'deptno';
EXEC #uep @name=N'MS_Description', @value=N'部門名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'dept_name';
EXEC #uep @name=N'MS_Description', @value=N'職位代號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'jobno';
EXEC #uep @name=N'MS_Description', @value=N'職稱名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'job_name';
EXEC #uep @name=N'MS_Description', @value=N'服務別 (例: 直接/間接)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'ind_svc';
EXEC #uep @name=N'MS_Description', @value=N'費用等級代號 (決定餐費級距)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'clsno';
EXEC #uep @name=N'MS_Description', @value=N'費用等級類別 (對應 sysset 餐費矩陣維度)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'clsno_kind';
EXEC #uep @name=N'MS_Description', @value=N'服務類別代號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'svctno';
EXEC #uep @name=N'MS_Description', @value=N'職等代號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'rnkno';
EXEC #uep @name=N'MS_Description', @value=N'職等名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'rank';
EXEC #uep @name=N'MS_Description', @value=N'無卡旗標 (Y=無卡員工/N=持卡)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'nocard';
EXEC #uep @name=N'MS_Description', @value=N'餐卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'cardnu';
EXEC #uep @name=N'MS_Description', @value=N'卡片有效起始日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'card_str_dte';
EXEC #uep @name=N'MS_Description', @value=N'卡片有效截止日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'card_end_dte';
EXEC #uep @name=N'MS_Description', @value=N'員工照片 (二進位 IMAGE)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'photo';
EXEC #uep @name=N'MS_Description', @value=N'照片識別碼 (二進位 IMAGE)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employ', @level2type=N'COLUMN',@level2name=N'photo_no';
GO

-- ============ saloon_records (POS 刷卡記錄) ============
EXEC #uep @name=N'MS_Description', @value=N'POS 餐廳刷卡消費記錄表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK, 自動遞增)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'工廠代號 (例: TC=台中廠)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'factory_code';
EXEC #uep @name=N'MS_Description', @value=N'標準化日期 (格式: YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'ndate';
EXEC #uep @name=N'MS_Description', @value=N'餐別類型 (對應用餐時段)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'kind';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/刷卡機編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (FK→employ.empno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'empno';
EXEC #uep @name=N'MS_Description', @value=N'資料來源 (1=設備自動/2=手動補登)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'datasource';
EXEC #uep @name=N'MS_Description', @value=N'刷卡日期 (格式: YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'carddate';
EXEC #uep @name=N'MS_Description', @value=N'刷卡時間 (格式: HHMMSS)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'cardtime';
EXEC #uep @name=N'MS_Description', @value=N'費用等級類別 (對應 employ.clsno_kind)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'clsno_kind';
EXEC #uep @name=N'MS_Description', @value=N'費用類別數值', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'kind_num';
EXEC #uep @name=N'MS_Description', @value=N'公司補助金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'amt1';
EXEC #uep @name=N'MS_Description', @value=N'外包/其他費用金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'amt3';
EXEC #uep @name=N'MS_Description', @value=N'員工自付金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'amt2';
EXEC #uep @name=N'MS_Description', @value=N'總餐費金額 (元, amt1+amt2+amt3)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'amt';
EXEC #uep @name=N'MS_Description', @value=N'刷卡卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'對應取消記錄序號 (不為空時表示已作廢)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'cancel_sno';
EXEC #uep @name=N'MS_Description', @value=N'餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'code';
EXEC #uep @name=N'MS_Description', @value=N'資料已上傳後端旗標 (Y=已上傳/N=待上傳)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'saloon_records', @level2type=N'COLUMN',@level2name=N'data_load';
GO

-- ============ sysset (POS 系統參數) ============
EXEC #uep @name=N'MS_Description', @value=N'POS 刷卡機系統參數設定表 (單筆)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset';
EXEC #uep @name=N'MS_Description', @value=N'編號 (PK, 固定值=1)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'no';
EXEC #uep @name=N'MS_Description', @value=N'公司名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'compy';
EXEC #uep @name=N'MS_Description', @value=N'工廠代號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'factory_code';
EXEC #uep @name=N'MS_Description', @value=N'工廠名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'factory_name';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 開始時間 (格式: HHMMSS)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime1';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 結束時間 (格式: HHMMSS)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime1';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime2';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime2';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime3';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime3';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime4';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime4';
-- 餐費金額矩陣: amt[時段][費用類別][員工類別]
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別1-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt111';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別1-員工類別3 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt113';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別1-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt112';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別2-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt121';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別2-員工類別3 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt123';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別2-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt122';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別3-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt131';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別3-員工類別3 餐費(元) [疑似命名異常: amt1133]', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt1133';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別3-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt132';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別4-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt141';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別4-員工類別3 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt143';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-費用類別4-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt142';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別1-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt211';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別1-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt212';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別2-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt221';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別2-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt222';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別3-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt231';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別3-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt232';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別4-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt241';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-費用類別4-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt242';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別1-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt311';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別1-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt312';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別2-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt321';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別2-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt322';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別3-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt331';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別3-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt332';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別4-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt341';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-費用類別4-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt342';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別1-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt411';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別1-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt412';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別2-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt421';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別2-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt422';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別3-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt431';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別3-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt432';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別4-員工類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt441';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-費用類別4-員工類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt442';
EXEC #uep @name=N'MS_Description', @value=N'防重複刷卡間隔秒數 (同一張卡須間隔此秒數才可再刷)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'repeat_seconds';
EXEC #uep @name=N'MS_Description', @value=N'POS 畫面空白預設照片 (二進位 IMAGE)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'space_photo';
EXEC #uep @name=N'MS_Description', @value=N'無照片員工預設顯示圖示 (二進位 IMAGE)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'no_photo';
GO

-- ============ app_pbd (程式版本管理) ============
EXEC #uep @name=N'MS_Description', @value=N'PowerBuilder PBD 程式版本管理表 (用於系統自動升版)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd';
EXEC #uep @name=N'MS_Description', @value=N'PBD 檔案名稱 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'fname';
EXEC #uep @name=N'MS_Description', @value=N'檔案大小 (bytes)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'fsize';
EXEC #uep @name=N'MS_Description', @value=N'主版本號 (Major)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'major';
EXEC #uep @name=N'MS_Description', @value=N'次版本號 (Minor)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'minor';
EXEC #uep @name=N'MS_Description', @value=N'建置號碼 (Build)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'build';
EXEC #uep @name=N'MS_Description', @value=N'修訂號碼 (Revision)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'revision';
EXEC #uep @name=N'MS_Description', @value=N'狀態旗標 (A=正式/T=測試)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'status';
EXEC #uep @name=N'MS_Description', @value=N'版本字串 (例: 1.7.8.21)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'version';
EXEC #uep @name=N'MS_Description', @value=N'檔案上傳至資料庫日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'upload_date';
EXEC #uep @name=N'MS_Description', @value=N'PBD 檔案二進位內容 (用於自動部署)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'fdata';
GO

-- ============================================================
-- PowerBuilder 系統表 (pbcat*) — 共 5 張
-- 由 PowerBuilder IDE 自動建立，儲存 DataWindow 物件的格式、
-- 驗證、欄位定義等 Metadata，非業務資料，請勿手動修改
-- ============================================================

-- ============ pbcattbl (DataWindow 資料表定義) ============
EXEC #uep @name=N'MS_Description', @value=N'[PB系統表] PowerBuilder DataWindow 資料表定義與顯示屬性',
    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl';
EXEC #uep @name=N'MS_Description', @value=N'資料表名稱 (PK)',                     @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbt_tnam';
EXEC #uep @name=N'MS_Description', @value=N'資料表識別碼',                        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbt_tid';
EXEC #uep @name=N'MS_Description', @value=N'資料表擁有者',                        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbt_ownr';
EXEC #uep @name=N'MS_Description', @value=N'預設區字型高度 (Twips)',              @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_fhgt';
EXEC #uep @name=N'MS_Description', @value=N'預設區字型粗細 (400=正常/700=粗體)',  @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_fwgt';
EXEC #uep @name=N'MS_Description', @value=N'預設區斜體旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_fitl';
EXEC #uep @name=N'MS_Description', @value=N'預設區底線旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_funl';
EXEC #uep @name=N'MS_Description', @value=N'預設區字元集',                        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_fchr';
EXEC #uep @name=N'MS_Description', @value=N'預設區字型間距',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_fptc';
EXEC #uep @name=N'MS_Description', @value=N'預設區字型名稱',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbd_ffce';
EXEC #uep @name=N'MS_Description', @value=N'標題列字型高度 (Twips)',              @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_fhgt';
EXEC #uep @name=N'MS_Description', @value=N'標題列字型粗細',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_fwgt';
EXEC #uep @name=N'MS_Description', @value=N'標題列斜體旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_fitl';
EXEC #uep @name=N'MS_Description', @value=N'標題列底線旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_funl';
EXEC #uep @name=N'MS_Description', @value=N'標題列字元集',                        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_fchr';
EXEC #uep @name=N'MS_Description', @value=N'標題列字型間距',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_fptc';
EXEC #uep @name=N'MS_Description', @value=N'標題列字型名稱',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbh_ffce';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄字型高度 (Twips)',              @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_fhgt';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄字型粗細',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_fwgt';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄斜體旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_fitl';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄底線旗標 (Y/N)',               @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_funl';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄字元集',                        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_fchr';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄字型間距',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_fptc';
EXEC #uep @name=N'MS_Description', @value=N'標籤欄字型名稱',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbl_ffce';
EXEC #uep @name=N'MS_Description', @value=N'資料表備註說明',                      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcattbl', @level2type=N'COLUMN',@level2name=N'pbt_cmnt';
GO

-- ============ pbcatcol (DataWindow 欄位定義) ============
EXEC #uep @name=N'MS_Description', @value=N'[PB系統表] PowerBuilder DataWindow 欄位顯示與格式定義',
    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol';
EXEC #uep @name=N'MS_Description', @value=N'資料表名稱 (PK)',      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_tnam';
EXEC #uep @name=N'MS_Description', @value=N'資料表識別碼 (PK)',    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_tid';
EXEC #uep @name=N'MS_Description', @value=N'資料表擁有者 (PK)',    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_ownr';
EXEC #uep @name=N'MS_Description', @value=N'欄位名稱 (PK)',        @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_cnam';
EXEC #uep @name=N'MS_Description', @value=N'欄位識別碼/順序',      @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_cid';
EXEC #uep @name=N'MS_Description', @value=N'欄位顯示標籤文字',    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_labl';
EXEC #uep @name=N'MS_Description', @value=N'標籤對齊方式',         @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_lpos';
EXEC #uep @name=N'MS_Description', @value=N'標題文字',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_hdr';
EXEC #uep @name=N'MS_Description', @value=N'標題對齊方式',         @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_hpos';
EXEC #uep @name=N'MS_Description', @value=N'內容對齊方式',         @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_jtfy';
EXEC #uep @name=N'MS_Description', @value=N'顯示格式代號 (FK→pbcatfmt)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_mask';
EXEC #uep @name=N'MS_Description', @value=N'大小寫設定',           @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_case';
EXEC #uep @name=N'MS_Description', @value=N'顯示高度',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_hght';
EXEC #uep @name=N'MS_Description', @value=N'顯示寬度',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_wdth';
EXEC #uep @name=N'MS_Description', @value=N'填充圖案',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_ptrn';
EXEC #uep @name=N'MS_Description', @value=N'點陣圖旗標',           @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_bmap';
EXEC #uep @name=N'MS_Description', @value=N'欄位初始值',           @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_init';
EXEC #uep @name=N'MS_Description', @value=N'備註說明',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_cmnt';
EXEC #uep @name=N'MS_Description', @value=N'編輯樣式代號 (FK→pbcatedt)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_edit';
EXEC #uep @name=N'MS_Description', @value=N'標籤字串',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatcol', @level2type=N'COLUMN',@level2name=N'pbc_tag';
GO

-- ============ pbcatfmt (顯示格式定義) ============
EXEC #uep @name=N'MS_Description', @value=N'[PB系統表] PowerBuilder DataWindow 欄位顯示格式定義',
    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatfmt';
EXEC #uep @name=N'MS_Description', @value=N'格式名稱 (PK)',                             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatfmt', @level2type=N'COLUMN',@level2name=N'pbf_name';
EXEC #uep @name=N'MS_Description', @value=N'格式字串 (例: dd/mm/yyyy、#,##0.00)',       @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatfmt', @level2type=N'COLUMN',@level2name=N'pbf_frmt';
EXEC #uep @name=N'MS_Description', @value=N'適用資料類型',                              @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatfmt', @level2type=N'COLUMN',@level2name=N'pbf_type';
EXEC #uep @name=N'MS_Description', @value=N'計數器',                                    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatfmt', @level2type=N'COLUMN',@level2name=N'pbf_cntr';
GO

-- ============ pbcatvld (欄位驗證規則) ============
EXEC #uep @name=N'MS_Description', @value=N'[PB系統表] PowerBuilder DataWindow 欄位驗證規則定義',
    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld';
EXEC #uep @name=N'MS_Description', @value=N'驗證規則名稱 (PK)',                         @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld', @level2type=N'COLUMN',@level2name=N'pbv_name';
EXEC #uep @name=N'MS_Description', @value=N'驗證運算式 (PB語法)',                       @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld', @level2type=N'COLUMN',@level2name=N'pbv_vald';
EXEC #uep @name=N'MS_Description', @value=N'適用資料類型',                              @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld', @level2type=N'COLUMN',@level2name=N'pbv_type';
EXEC #uep @name=N'MS_Description', @value=N'計數器',                                    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld', @level2type=N'COLUMN',@level2name=N'pbv_cntr';
EXEC #uep @name=N'MS_Description', @value=N'驗證失敗提示訊息',                          @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatvld', @level2type=N'COLUMN',@level2name=N'pbv_msg';
GO

-- ============ pbcatedt (下拉式選單定義) ============
EXEC #uep @name=N'MS_Description', @value=N'[PB系統表] PowerBuilder DataWindow 下拉式選單 (DropDownDW/DDDW) 定義',
    @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt';
EXEC #uep @name=N'MS_Description', @value=N'選單名稱 (PK)',       @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_name';
EXEC #uep @name=N'MS_Description', @value=N'編輯樣式定義字串',   @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_edit';
EXEC #uep @name=N'MS_Description', @value=N'編輯樣式類型',       @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_type';
EXEC #uep @name=N'MS_Description', @value=N'計數器',             @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_cntr';
EXEC #uep @name=N'MS_Description', @value=N'項目序號',           @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_seqn';
EXEC #uep @name=N'MS_Description', @value=N'顯示旗標',           @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_flag';
EXEC #uep @name=N'MS_Description', @value=N'工作區欄位',         @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'pbcatedt', @level2type=N'COLUMN',@level2name=N'pbe_work';
GO
