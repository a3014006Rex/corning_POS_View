USE [Corning_Dining_TC];
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


-- ============ depart ============
EXEC #uep @name=N'MS_Description', @value=N'部門資料表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'depart';
EXEC #uep @name=N'MS_Description', @value=N'部門代號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'depart', @level2type=N'COLUMN',@level2name=N'departno';
EXEC #uep @name=N'MS_Description', @value=N'部門名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'depart', @level2type=N'COLUMN',@level2name=N'depart';
EXEC #uep @name=N'MS_Description', @value=N'部門類別', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'depart', @level2type=N'COLUMN',@level2name=N'kind';
GO

-- ============ jobplace ============
EXEC #uep @name=N'MS_Description', @value=N'工作地點資料表 (TC台中廠/TN台南廠/TP新竹/TT台北)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'jobplace';
EXEC #uep @name=N'MS_Description', @value=N'工作地點代號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'jobplace', @level2type=N'COLUMN',@level2name=N'jpno';
EXEC #uep @name=N'MS_Description', @value=N'工作地點名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'jobplace', @level2type=N'COLUMN',@level2name=N'jpname';
GO

-- ============ employee ============
EXEC #uep @name=N'MS_Description', @value=N'員工基本資料表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee';
EXEC #uep @name=N'MS_Description', @value=N'部門代號 (FK→depart.departno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'departno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'員工姓名', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'name';
EXEC #uep @name=N'MS_Description', @value=N'餐卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'工號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'workid';
EXEC #uep @name=N'MS_Description', @value=N'工作地點代號 (FK→jobplace.jpno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'jpno';
EXEC #uep @name=N'MS_Description', @value=N'員工類別 (1=正職/2=約聘/3=外包)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'kind';
EXEC #uep @name=N'MS_Description', @value=N'登入密碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'password';
EXEC #uep @name=N'MS_Description', @value=N'系統使用者ID', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'employee', @level2type=N'COLUMN',@level2name=N'UserId';
GO

-- ============ tcardno ============
EXEC #uep @name=N'MS_Description', @value=N'員工正式餐卡號碼對應表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'餐卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (FK→employee.eno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'有效起始日期 (YYYYMMDD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'sdate';
EXEC #uep @name=N'MS_Description', @value=N'卡片類型', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'ctype';
EXEC #uep @name=N'MS_Description', @value=N'有效截止日期 (YYYYMMDD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tcardno', @level2type=N'COLUMN',@level2name=N'edate';
GO

-- ============ m_tcardno ============
EXEC #uep @name=N'MS_Description', @value=N'員工正式餐卡號碼對應表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'餐卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'有效起始日期 (YYYYMMDD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'sdate';
EXEC #uep @name=N'MS_Description', @value=N'卡片類型', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'ctype';
EXEC #uep @name=N'MS_Description', @value=N'有效截止日期 (YYYYMMDD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tcardno', @level2type=N'COLUMN',@level2name=N'edate';
GO

-- ============ tempcardno ============
EXEC #uep @name=N'MS_Description', @value=N'員工臨時餐卡對應表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'臨時卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (FK→employee.eno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'有效起始日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'sdate';
EXEC #uep @name=N'MS_Description', @value=N'卡片類型', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'ctype';
EXEC #uep @name=N'MS_Description', @value=N'有效截止日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno', @level2type=N'COLUMN',@level2name=N'edate';
GO

-- ============ m_tempcardno ============
EXEC #uep @name=N'MS_Description', @value=N'員工臨時餐卡對應表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'臨時卡號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'有效起始日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'sdate';
EXEC #uep @name=N'MS_Description', @value=N'卡片類型', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'ctype';
EXEC #uep @name=N'MS_Description', @value=N'有效截止日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno', @level2type=N'COLUMN',@level2name=N'edate';
GO

-- ============ tempcardno_set ============
EXEC #uep @name=N'MS_Description', @value=N'臨時卡發卡/廢卡設定表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno_set';
EXEC #uep @name=N'MS_Description', @value=N'臨時卡號碼 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno_set', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'持卡人姓名', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno_set', @level2type=N'COLUMN',@level2name=N'cardname';
EXEC #uep @name=N'MS_Description', @value=N'廢卡旗標 (Y=已廢卡/N=有效)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno_set', @level2type=N'COLUMN',@level2name=N'annul';
EXEC #uep @name=N'MS_Description', @value=N'廢卡原因說明', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tempcardno_set', @level2type=N'COLUMN',@level2name=N'cause';
GO

-- ============ m_tempcardno_set ============
EXEC #uep @name=N'MS_Description', @value=N'臨時卡發卡/廢卡設定表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno_set';
EXEC #uep @name=N'MS_Description', @value=N'臨時卡號碼 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno_set', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'持卡人姓名', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno_set', @level2type=N'COLUMN',@level2name=N'cardname';
EXEC #uep @name=N'MS_Description', @value=N'廢卡旗標 (Y=已廢卡/N=有效)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno_set', @level2type=N'COLUMN',@level2name=N'annul';
EXEC #uep @name=N'MS_Description', @value=N'廢卡原因說明', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_tempcardno_set', @level2type=N'COLUMN',@level2name=N'cause';
GO

-- ============ subsidy_period ============
EXEC #uep @name=N'MS_Description', @value=N'員工餐飲補助有效期間設定表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'subsidy_period';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'subsidy_period', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (FK→employee.eno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'subsidy_period', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'補助起始日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'subsidy_period', @level2type=N'COLUMN',@level2name=N'start_date';
EXEC #uep @name=N'MS_Description', @value=N'補助截止日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'subsidy_period', @level2type=N'COLUMN',@level2name=N'deadline';
GO

-- ============ time_recording ============
EXEC #uep @name=N'MS_Description', @value=N'員工刷卡用餐記錄主檔', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (FK→employee.eno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'刷卡卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/刷卡設備編號 (FK→time_recording_set.mnbr)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'資料來源 (1=設備自動/2=手動補登)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'datasource';
EXEC #uep @name=N'MS_Description', @value=N'刷卡日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'carddate';
EXEC #uep @name=N'MS_Description', @value=N'刷卡時間 (HHMMSS)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'cardtime';
EXEC #uep @name=N'MS_Description', @value=N'餐別代碼 (對應用餐時段)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'code';
EXEC #uep @name=N'MS_Description', @value=N'備註說明', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'note';
EXEC #uep @name=N'MS_Description', @value=N'原始刷卡記錄原文', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'recording';
EXEC #uep @name=N'MS_Description', @value=N'歸屬記帳日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'rdate';
EXEC #uep @name=N'MS_Description', @value=N'手動鍵入日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'keyin_date';
EXEC #uep @name=N'MS_Description', @value=N'手動鍵入操作員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'keyin_eno';
EXEC #uep @name=N'MS_Description', @value=N'最後修改日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'modify_date';
EXEC #uep @name=N'MS_Description', @value=N'最後修改操作員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'modify_eno';
EXEC #uep @name=N'MS_Description', @value=N'標準化日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'ndate';
EXEC #uep @name=N'MS_Description', @value=N'記錄類別 (1=正常/2=補登/3=作廢)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'kind';
EXEC #uep @name=N'MS_Description', @value=N'對應取消記錄序號 (FK→time_recording_cancel.sno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'cancel_sno';
EXEC #uep @name=N'MS_Description', @value=N'員工類別數值 (對應費用級距)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'kind_num';
EXEC #uep @name=N'MS_Description', @value=N'公司補助金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'amount1';
EXEC #uep @name=N'MS_Description', @value=N'員工自付金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'amount2';
EXEC #uep @name=N'MS_Description', @value=N'外包/其他費用金額 (元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording', @level2type=N'COLUMN',@level2name=N'amount3';
GO

-- ============ m_time_recording ============
EXEC #uep @name=N'MS_Description', @value=N'員工刷卡用餐記錄主檔 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'刷卡卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/刷卡設備編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'資料來源 (1=設備自動/2=手動補登)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'datasource';
EXEC #uep @name=N'MS_Description', @value=N'刷卡日期 (YYYY-MM-DD)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'carddate';
EXEC #uep @name=N'MS_Description', @value=N'刷卡時間 (HHMMSS)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'cardtime';
EXEC #uep @name=N'MS_Description', @value=N'餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'code';
EXEC #uep @name=N'MS_Description', @value=N'備註說明', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'note';
EXEC #uep @name=N'MS_Description', @value=N'原始刷卡記錄原文', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'recording';
EXEC #uep @name=N'MS_Description', @value=N'歸屬記帳日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'rdate';
EXEC #uep @name=N'MS_Description', @value=N'手動鍵入日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'keyin_date';
EXEC #uep @name=N'MS_Description', @value=N'手動鍵入操作員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'keyin_eno';
EXEC #uep @name=N'MS_Description', @value=N'最後修改日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'modify_date';
EXEC #uep @name=N'MS_Description', @value=N'最後修改操作員工編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'modify_eno';
EXEC #uep @name=N'MS_Description', @value=N'標準化日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'ndate';
EXEC #uep @name=N'MS_Description', @value=N'記錄類別', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'kind';
EXEC #uep @name=N'MS_Description', @value=N'對應取消記錄序號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording', @level2type=N'COLUMN',@level2name=N'cancel_sno';
GO

-- ============ time_recording_cancel ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡用餐作廢/取消記錄表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'被取消的卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'原刷卡日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel', @level2type=N'COLUMN',@level2name=N'carddate';
EXEC #uep @name=N'MS_Description', @value=N'原刷卡時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel', @level2type=N'COLUMN',@level2name=N'cardtime';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cancel', @level2type=N'COLUMN',@level2name=N'mnbr';
GO

-- ============ m_time_recording_cancel ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡用餐作廢/取消記錄表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'被取消的卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'原刷卡日期', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel', @level2type=N'COLUMN',@level2name=N'carddate';
EXEC #uep @name=N'MS_Description', @value=N'原刷卡時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel', @level2type=N'COLUMN',@level2name=N'cardtime';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cancel', @level2type=N'COLUMN',@level2name=N'mnbr';
GO

-- ============ time_recording_cardno ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡設備與管理員卡號對應表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cardno';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cardno', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'管理員卡號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'系統使用者ID', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_cardno', @level2type=N'COLUMN',@level2name=N'UserId';
GO

-- ============ m_time_recording_cardno ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡設備與管理員卡號對應表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cardno';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cardno', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'管理員卡號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cardno', @level2type=N'COLUMN',@level2name=N'cardno';
EXEC #uep @name=N'MS_Description', @value=N'系統使用者ID', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_cardno', @level2type=N'COLUMN',@level2name=N'UserId';
GO

-- ============ time_recording_set ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡設備通訊與費用設定表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'接收資料旗標 (Y=啟用/N=停用)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'recv';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號 (唯一識別)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'設備型號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'model';
EXEC #uep @name=N'MS_Description', @value=N'通訊協定 (1=TCP/IP, 2=RS232)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'comm_protocol';
EXEC #uep @name=N'MS_Description', @value=N'設備 IP 位址', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'ip';
EXEC #uep @name=N'MS_Description', @value=N'TCP 通訊埠號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'port';
EXEC #uep @name=N'MS_Description', @value=N'連線逾時秒數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'overtime';
EXEC #uep @name=N'MS_Description', @value=N'RS232 COM 埠號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'comport';
EXEC #uep @name=N'MS_Description', @value=N'RS232 鮑率 (baud rate)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'baud';
EXEC #uep @name=N'MS_Description', @value=N'同位元檢查 (N/E/O)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'parity';
EXEC #uep @name=N'MS_Description', @value=N'資料位元數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'c_bit';
EXEC #uep @name=N'MS_Description', @value=N'停止位元數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'c_stop';
EXEC #uep @name=N'MS_Description', @value=N'設備名稱/餐廳名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'name';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt11';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt12';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt21';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt22';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt31';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt32';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt41';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'time_recording_set', @level2type=N'COLUMN',@level2name=N'amt42';
GO

-- ============ m_time_recording_set ============
EXEC #uep @name=N'MS_Description', @value=N'刷卡設備通訊與費用設定表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'sno';
EXEC #uep @name=N'MS_Description', @value=N'接收資料旗標', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'recv';
EXEC #uep @name=N'MS_Description', @value=N'餐廳/設備編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'mnbr';
EXEC #uep @name=N'MS_Description', @value=N'設備型號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'model';
EXEC #uep @name=N'MS_Description', @value=N'通訊協定', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'comm_protocol';
EXEC #uep @name=N'MS_Description', @value=N'設備 IP 位址', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'ip';
EXEC #uep @name=N'MS_Description', @value=N'TCP 通訊埠號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'port';
EXEC #uep @name=N'MS_Description', @value=N'連線逾時秒數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'overtime';
EXEC #uep @name=N'MS_Description', @value=N'RS232 COM 埠號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'comport';
EXEC #uep @name=N'MS_Description', @value=N'RS232 鮑率', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'baud';
EXEC #uep @name=N'MS_Description', @value=N'同位元檢查', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'parity';
EXEC #uep @name=N'MS_Description', @value=N'資料位元數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'c_bit';
EXEC #uep @name=N'MS_Description', @value=N'停止位元數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'c_stop';
EXEC #uep @name=N'MS_Description', @value=N'設備名稱/餐廳名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'name';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt11';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt12';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt21';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt22';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt31';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt32';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-類別1 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt41';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-類別2 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_time_recording_set', @level2type=N'COLUMN',@level2name=N'amt42';
GO

-- ============ sysset ============
EXEC #uep @name=N'MS_Description', @value=N'系統全域參數設定表 (單筆)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset';
EXEC #uep @name=N'MS_Description', @value=N'編號 (PK, 固定值=1)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'no';
EXEC #uep @name=N'MS_Description', @value=N'公司名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'compy';
EXEC #uep @name=N'MS_Description', @value=N'資料庫備份路徑', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'backuppath';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始卡號範圍', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'scardnonbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束卡號範圍', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'ecardnonbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始年份', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'syearnbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束年份', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'eyearnbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始日(日)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'sdatenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束日(日)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'edatenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stimenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etimenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'scodenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'ecodenbr';
EXEC #uep @name=N'MS_Description', @value=N'起始餐廳編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'smnbr';
EXEC #uep @name=N'MS_Description', @value=N'結束餐廳編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'emnbr';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄1', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_1';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄2', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_2';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄3', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_3';
EXEC #uep @name=N'MS_Description', @value=N'記錄檔副檔名前綴', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'subfilename';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime1';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime1';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime2';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime2';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime3';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime3';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'stime4';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'etime4';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt11';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt12';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt21';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt22';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt31';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt32';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt41';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'amt42';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號1', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'door_no11';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號2', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'door_no12';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號3', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'door_no13';
EXEC #uep @name=N'MS_Description', @value=N'卡號格式驗證旗標 (Y=啟用)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysset', @level2type=N'COLUMN',@level2name=N'cardno_chk';
GO

-- ============ m_sysset ============
EXEC #uep @name=N'MS_Description', @value=N'系統全域參數設定表 (Mirror備援)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset';
EXEC #uep @name=N'MS_Description', @value=N'編號 (PK, 固定值=1)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'no';
EXEC #uep @name=N'MS_Description', @value=N'公司名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'compy';
EXEC #uep @name=N'MS_Description', @value=N'資料庫備份路徑', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'backuppath';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始卡號範圍', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'scardnonbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束卡號範圍', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'ecardnonbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始年份', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'syearnbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束年份', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'eyearnbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始日(日)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'sdatenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束日(日)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'edatenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'stimenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'etimenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢起始餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'scodenbr';
EXEC #uep @name=N'MS_Description', @value=N'查詢結束餐別代碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'ecodenbr';
EXEC #uep @name=N'MS_Description', @value=N'起始餐廳編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'smnbr';
EXEC #uep @name=N'MS_Description', @value=N'結束餐廳編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'emnbr';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄1', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_1';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄2', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_2';
EXEC #uep @name=N'MS_Description', @value=N'刷卡記錄檔匯入目錄3', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'rec_directory_3';
EXEC #uep @name=N'MS_Description', @value=N'記錄檔副檔名前綴', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'subfilename';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'stime1';
EXEC #uep @name=N'MS_Description', @value=N'第1用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'etime1';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'stime2';
EXEC #uep @name=N'MS_Description', @value=N'第2用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'etime2';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'stime3';
EXEC #uep @name=N'MS_Description', @value=N'第3用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'etime3';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 開始時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'stime4';
EXEC #uep @name=N'MS_Description', @value=N'第4用餐時段 結束時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'etime4';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt11';
EXEC #uep @name=N'MS_Description', @value=N'第1時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt12';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt21';
EXEC #uep @name=N'MS_Description', @value=N'第2時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt22';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt31';
EXEC #uep @name=N'MS_Description', @value=N'第3時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt32';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-正職員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt41';
EXEC #uep @name=N'MS_Description', @value=N'第4時段-約聘員工 餐費(元)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'amt42';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號1', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'door_no11';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號2', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'door_no12';
EXEC #uep @name=N'MS_Description', @value=N'門禁控制器編號3', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'door_no13';
EXEC #uep @name=N'MS_Description', @value=N'卡號格式驗證旗標 (Y=啟用)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'm_sysset', @level2type=N'COLUMN',@level2name=N'cardno_chk';
GO

-- ============ security ============
EXEC #uep @name=N'MS_Description', @value=N'使用者功能操作權限表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (PK, FK→employee.eno)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'功能視窗名稱 (PK, FK→progname.program_no)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_window';
EXEC #uep @name=N'MS_Description', @value=N'執行權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_run';
EXEC #uep @name=N'MS_Description', @value=N'新增資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_insert';
EXEC #uep @name=N'MS_Description', @value=N'修改資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_edit';
EXEC #uep @name=N'MS_Description', @value=N'刪除資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_delete';
EXEC #uep @name=N'MS_Description', @value=N'查詢資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_query';
EXEC #uep @name=N'MS_Description', @value=N'列印報表權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_print';
EXEC #uep @name=N'MS_Description', @value=N'審核資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'security', @level2type=N'COLUMN',@level2name=N's_verify';
GO

-- ============ securitytmp ============
EXEC #uep @name=N'MS_Description', @value=N'使用者功能操作權限暫存表 (異動編輯用)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp';
EXEC #uep @name=N'MS_Description', @value=N'員工編號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N'eno';
EXEC #uep @name=N'MS_Description', @value=N'功能視窗名稱 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_window';
EXEC #uep @name=N'MS_Description', @value=N'執行權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_run';
EXEC #uep @name=N'MS_Description', @value=N'新增資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_insert';
EXEC #uep @name=N'MS_Description', @value=N'修改資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_edit';
EXEC #uep @name=N'MS_Description', @value=N'刪除資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_delete';
EXEC #uep @name=N'MS_Description', @value=N'查詢資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_query';
EXEC #uep @name=N'MS_Description', @value=N'列印報表權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_print';
EXEC #uep @name=N'MS_Description', @value=N'審核資料權限 (Y/N)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'securitytmp', @level2type=N'COLUMN',@level2name=N's_verify';
GO

-- ============ progname ============
EXEC #uep @name=N'MS_Description', @value=N'系統功能選單結構表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname';
EXEC #uep @name=N'MS_Description', @value=N'程式/功能代號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'program_no';
EXEC #uep @name=N'MS_Description', @value=N'程式/功能名稱 (顯示文字)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'program_name';
EXEC #uep @name=N'MS_Description', @value=N'上層選單代號 (根節點為空)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'up_no';
EXEC #uep @name=N'MS_Description', @value=N'是否可執行 (Y=可點選/N=群組節點)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'run_yn';
EXEC #uep @name=N'MS_Description', @value=N'選單層級', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'levela';
EXEC #uep @name=N'MS_Description', @value=N'功能說明文字', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'describe';
EXEC #uep @name=N'MS_Description', @value=N'圖示索引值', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'program_pictureindex';
EXEC #uep @name=N'MS_Description', @value=N'排序號碼', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'progname', @level2type=N'COLUMN',@level2name=N'sortnbr';
GO

-- ============ lcc ============
EXEC #uep @name=N'MS_Description', @value=N'系統操作日誌/指令記錄表', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc';
EXEC #uep @name=N'MS_Description', @value=N'序號 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'serno';
EXEC #uep @name=N'MS_Description', @value=N'記錄日期時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'fdate';
EXEC #uep @name=N'MS_Description', @value=N'指令等級/優先權', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'cmdlv';
EXEC #uep @name=N'MS_Description', @value=N'指令名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'cmd';
EXEC #uep @name=N'MS_Description', @value=N'指令資料內容', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'data';
EXEC #uep @name=N'MS_Description', @value=N'控制器/設備編號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'ctrno';
EXEC #uep @name=N'MS_Description', @value=N'來源端 IP 位址', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'fromip';
EXEC #uep @name=N'MS_Description', @value=N'錯誤累計次數', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'errorcount';
EXEC #uep @name=N'MS_Description', @value=N'操作者使用者ID', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'UserId';
EXEC #uep @name=N'MS_Description', @value=N'操作者卡號', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'lcc', @level2type=N'COLUMN',@level2name=N'cardno';
GO

-- ============ app_pbd ============
EXEC #uep @name=N'MS_Description', @value=N'PowerBuilder PBD 程式版本管理表 (用於系統自動升版)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd';
EXEC #uep @name=N'MS_Description', @value=N'應用程式名稱 (PK)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'app';
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
EXEC #uep @name=N'MS_Description', @value=N'對應程式名稱', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'app_pbd', @level2type=N'COLUMN',@level2name=N'prg';
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