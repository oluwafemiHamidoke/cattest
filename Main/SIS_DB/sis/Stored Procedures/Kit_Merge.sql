CREATE PROCEDURE [sis].[Kit_Merge] (@DEBUG BIT = 'FALSE')
AS
BEGIN

	SET NOCOUNT ON;

    BEGIN TRY
	
        DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@ProcName                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@ProcessID                     UNIQUEIDENTIFIER = NEWID()

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)
        
        BEGIN TRANSACTION;

		DROP TABLE IF EXISTS #Serviceability_Indicator;
        Select SERVICEABILITY, Substring(SERVICEABILITY,1,1) indicator
        into #Serviceability_Indicator
        from [KIM].[SIS_KitNumbers]
        group by SERVICEABILITY;


        DROP TABLE IF EXISTS #Serviceability_Indicator_KBOM;
        Select SERVICEABILITY, Substring(SERVICEABILITY,1,1) indicator
        into #Serviceability_Indicator_KBOM
        from [KIM].[SIS_KitBillOfMaterials]
        group by SERVICEABILITY;


        DECLARE @MERGE_RESULTS TABLE
			(ACTIONTYPE         NVARCHAR(10)
			,Number         VARCHAR(50) NOT NULL
			);

        MERGE [sis].[Kit] AS target
            USING (
                select kits.KitNumber, kits.PartName, kits.DisplayName, kits.Parttype, si.indicator , kits.KITNOTE, kits.[CHG. LVL] , kits.LONGDESCRIPTION
                from        [KIM].[SIS_KitNumbers]      kits
                inner join  #Serviceability_Indicator   si  on si.Serviceability = kits.Serviceability
            )
            AS source (kit_number, part_name, display_name, part_type, indicator, kitnote, change_level, long_description)
            ON (target.Number = source.kit_number)
            WHEN MATCHED AND EXISTS(SELECT source.part_name,source.display_name,source.part_type,source.indicator, source.kitnote, source.change_level, source.long_description
										EXCEPT
										SELECT target.Name, target.Display_Name, target.Part_Type, target.Serviceability_Indicator, target.Note, target.Change_Level, target.Long_Description)THEN
                UPDATE SET Name = source.part_name, Display_Name = source.display_name, Part_Type = source.part_type, Serviceability_Indicator = source.indicator, Note = source.kitnote, Change_Level = source.change_level, Long_Description = source.long_description
            WHEN NOT MATCHED THEN
                INSERT ([Number], [Name],[Display_Name],[Part_Type],[Serviceability_Indicator],[Note], [Change_Level], [Long_Description])
                VALUES (source.kit_number, source.part_name,source.display_name,source.part_type, source.indicator, source.kitnote, source.change_level, source.long_description)
			OUTPUT $ACTION,
				  COALESCE(inserted.Number, deleted.Number) Number
				   INTO @MERGE_RESULTS;

		SELECT @MERGED_ROWS = @@ROWCOUNT;

		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Kit Modified Rows');

        DROP TABLE #Serviceability_Indicator;

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, @LOGMESSAGE, @MERGED_ROWS);

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL);

        COMMIT;

    END TRY

    BEGIN CATCH 

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

	    IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                THROW;
            END

    END CATCH        

END