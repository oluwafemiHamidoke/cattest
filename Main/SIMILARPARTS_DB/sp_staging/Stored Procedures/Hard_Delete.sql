CREATE PROCEDURE  [sp_staging].[Hard_Delete]

AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

	DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	DECLARE @ProcessID uniqueidentifier = NewID()
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)
	
	
	--[sp].[Part_Properties] Hard Delete
	DELETE PP FROM [sp].[Part_Properties] PP
	WHERE PP.Attribute_ID IN (SELECT  Attribute_ID FROM sp.Attribute WHERE Attribute_Name IN (SELECT NAME FROM [sp_staging].[ATTRIBUTE_REMOVED]));
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.Part_Properties Hard Delete Completed', @@RowCount)

	UPDATE STATISTICS [sp].[Part_Properties] WITH FULLSCAN;

	--[sp].[Class_Attribute_Relation] Hard Delete
	DELETE CAR 
	FROM [sp].[Class_Attribute_Relation] CAR
	LEFT OUTER JOIN [sp_staging].[CLASS_ATTRIBUTES] CA ON CAR.[Class_ID] = CA.[CLASS_ID] AND CAR.[Attribute_ID] = CA.[ATTRIBUTE_ID]
	WHERE CAR.[Class_ID] IS NULL AND
	CAR.[Attribute_ID] IN (SELECT  Attribute_ID FROM sp.Attribute WHERE Attribute_Name IN (SELECT NAME FROM [sp_staging].[ATTRIBUTE_REMOVED]));
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp_staging.Class_Attribute_Relation Hard Delete Completed', @@RowCount)
		
	UPDATE STATISTICS [sp].[Class_Attribute_Relation] WITH FULLSCAN;

	--[sp].[Attribute] Hard Delete
	DELETE A FROM [sp].[Attribute] A
	LEFT OUTER JOIN [sp_staging].[ATTRIBUTE] SA ON A.[Attribute_Name] = SA.[NAME] 
	WHERE A.[Attribute_Name] IS NULL AND A.Attribute_ID IN (SELECT  Attribute_ID FROM sp.Attribute WHERE Attribute_Name IN (SELECT NAME FROM [sp_staging].[ATTRIBUTE_REMOVED]));
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.Attribute Hard Delete Completed', @@RowCount)

	UPDATE STATISTICS [sp].[Attribute] WITH FULLSCAN;
		
	--[sp].[Part] Hard Delete
	MERGE [sp].[Part] AS x USING 
		(
		SELECT distinct 
			c.ID AS Part_ID, 
			a.PART_NUMBER as Part_Number,
			b.Class_ID as Class_ID,
			a.REFRESHED_TS as LastModified_Date
		FROM sp_staging.PART_CLASS a
		inner join [sp].Class b ON a.CLASS_ID = b.Class_Number
		inner join sp_staging.PART c ON a.PART_NUMBER=c.PART_NUMBER
		) AS s
		ON (s.Part_Number = x.Part_Number)
		WHEN NOT MATCHED BY SOURCE
		THEN DELETE;
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.Part Hard Delete Completed', @@RowCount)

	UPDATE STATISTICS [sp].[Part] WITH FULLSCAN;

	--[sp].[Class] Hard Delete for Class involves creating the Class data FROM the [sp_staging].PDT 
	--without the Last Refreshed Date logic to check the entire data set for deleting Class records no longer valid. Calling procedure to perform Hard_Delete for sp.Class
	
	EXEC [sp_staging].[Class_Hard_Delete]
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.Class Hard Delete Completed', @@RowCount)

	UPDATE STATISTICS [sp].[Class] WITH FULLSCAN;
		
	--[sp].[List_Of_VALUES_Value] Hard Delete
	MERGE [sp].[List_Of_VALUES_Value] AS x USING 
		(
		SELECT DISTINCT x.List_Of_VALUES_ID,x.List_Of_VALUES_Name,x.List_Of_VALUES_Number
		FROM  sp.List_Of_VALUES x
		LEFT JOIN 
		(
		SELECT DISTINCT 
				ID AS List_Of_VALUES_Number,
				NAME AS List_Of_VALUES_Name, 
				FORMAT_VALUE AS Format_ValueList,
				A.REFRESHED_TS AS LastModified_Date
			FROM [sp_staging].[ATTRIBUTE] A
			INNER JOIN [sp_staging].[CLASS_ATTRIBUTES] C ON A.ID = C.ATTRIBUTE_ID
			WHERE FORMAT_VALUE IS NOT NULL AND FORMAT_VALUE LIKE '%|%'
		) s
		ON 
		(
		s.List_Of_VALUES_Name = x.List_Of_VALUES_Name AND
		s.List_Of_VALUES_Number = x.List_Of_VALUES_Number
		)
		WHERE s.List_Of_VALUES_Name IS NOT NULL
		) AS s
		ON 
		(s.List_Of_VALUES_ID = x.List_Of_VALUES_ID)
		WHEN NOT MATCHED BY SOURCE
		THEN DELETE;
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.List_Of_VALUES_Value Hard Delete Completed', @@RowCount)

	UPDATE STATISTICS [sp].[List_Of_VALUES_Value] WITH FULLSCAN
	
	--[sp].[[List_Of_VALUES]] Hard Delete
	MERGE [sp].[List_Of_VALUES] AS x USING 
		(
		SELECT DISTINCT 
			ID AS List_Of_VALUES_Number,
			NAME AS List_Of_VALUES_Name, 
			FORMAT_VALUE AS Format_ValueList,
			A.REFRESHED_TS AS LastModified_Date
		FROM [sp_staging].[ATTRIBUTE] A
		INNER JOIN [sp_staging].[CLASS_ATTRIBUTES] C ON A.ID = C.ATTRIBUTE_ID
		WHERE FORMAT_VALUE IS NOT NULL AND FORMAT_VALUE LIKE '%|%'
		) AS s
		ON 
		(
		s.List_Of_VALUES_Name = x.List_Of_VALUES_Name AND
		s.List_Of_VALUES_Number = x.List_Of_VALUES_Number
		)
		WHEN NOT MATCHED BY SOURCE
		THEN DELETE;
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'sp.List_Of_VALUES Hard Delete Completed', @@RowCount)
	
	UPDATE STATISTICS [sp].[List_Of_VALUES] WITH FULLSCAN;
		
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)
	
END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
	DECLARE @ERROELINE INT= ERROR_LINE()
	
	INSERT INTO [sp_staging].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	VALUES (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

END CATCH

END
