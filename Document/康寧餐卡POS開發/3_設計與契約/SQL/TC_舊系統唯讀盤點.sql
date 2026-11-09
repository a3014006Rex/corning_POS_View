-- TC 舊系統唯讀結構盤點 v1.0 / 2026-11-06
-- 只讀 metadata；不查員工、卡號或密碼內容；不建立、還原、修改或刪除資料。
-- 請 DBA 在已核准的隔離還原庫完整執行本批次。
-- 如果隔離庫使用不同名稱，先核對目標，再調整以下允許清單。
SET NOCOUNT ON;

IF DB_NAME() NOT IN (N'Corning_Dining_TC', N'Corning_POS_TC')
BEGIN
    RAISERROR(N'請先核對隔離目標資料庫；本腳本預設只允許 Corning_Dining_TC / Corning_POS_TC。', 16, 1);
    RETURN;
END;

SELECT DB_NAME() AS DatabaseName,
       CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS ProductVersion;

SELECT s.name AS SchemaName, t.name AS TableName,
       c.column_id AS ColumnOrder, c.name AS ColumnName,
       ty.name AS TypeName, c.max_length AS MaxLengthBytes,
       c.precision AS NumericPrecision, c.scale AS NumericScale,
       c.is_nullable AS IsNullable, c.is_identity AS IsIdentity,
       CASE WHEN c.default_object_id = 0 THEN 0 ELSE 1 END AS HasDefault
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
JOIN sys.columns AS c ON c.object_id = t.object_id
JOIN sys.types AS ty ON ty.user_type_id = c.user_type_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id;

SELECT s.name AS SchemaName, t.name AS TableName,
       i.name AS IndexName, i.is_primary_key AS IsPrimaryKey,
       i.is_unique AS IsUnique, i.type_desc AS IndexType,
       ic.key_ordinal AS KeyOrder, ic.is_included_column AS IsIncluded,
       c.name AS ColumnName
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
JOIN sys.indexes AS i ON i.object_id = t.object_id
JOIN sys.index_columns AS ic
  ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns AS c
  ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE t.is_ms_shipped = 0 AND i.index_id > 0
ORDER BY s.name, t.name, i.name, ic.key_ordinal, ic.index_column_id;

SELECT fk.name AS ForeignKeyName,
       ps.name AS ParentSchema, pt.name AS ParentTable, pc.name AS ParentColumn,
       rs.name AS ReferencedSchema, rt.name AS ReferencedTable, rc.name AS ReferencedColumn,
       fk.is_disabled AS IsDisabled, fk.is_not_trusted AS IsNotTrusted
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
JOIN sys.tables AS pt ON pt.object_id = fkc.parent_object_id
JOIN sys.schemas AS ps ON ps.schema_id = pt.schema_id
JOIN sys.columns AS pc
  ON pc.object_id = pt.object_id AND pc.column_id = fkc.parent_column_id
JOIN sys.tables AS rt ON rt.object_id = fkc.referenced_object_id
JOIN sys.schemas AS rs ON rs.schema_id = rt.schema_id
JOIN sys.columns AS rc
  ON rc.object_id = rt.object_id AND rc.column_id = fkc.referenced_column_id
ORDER BY ps.name, pt.name, fk.name, fkc.constraint_column_id;

-- 只列 View/SP/Trigger 名稱與修改時間，後續依確認範圍逐項追查定義及呼叫來源。
SELECT s.name AS SchemaName, o.name AS ObjectName,
       o.type_desc AS ObjectType, o.modify_date AS ModifiedAt
FROM sys.objects AS o
JOIN sys.schemas AS s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
  AND o.type IN ('V', 'P', 'TR', 'FN', 'IF', 'TF')
ORDER BY o.type_desc, s.name, o.name;

