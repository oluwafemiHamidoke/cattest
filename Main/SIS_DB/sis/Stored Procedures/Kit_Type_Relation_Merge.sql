CREATE PROCEDURE [sis].[Kit_Type_Relation_Merge] (@DEBUG BIT = 'FALSE')
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

        -- Load Kit_Type_Relation Table
        DECLARE @MERGE_RESULTS12 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Kit_ID         INT NOT NULL
			);

        BEGIN TRANSACTION;

        MERGE [sis].[Kit_Type_Relation] AS target  
            USING (
                select distinct kit.Kit_ID, kittype.KitType_ID 
                from        [KIM].[SIS_KitNumbers] kit_old
                inner join  [sis].[Kit] kit         on kit.Number   = kit_old.KITNUMBER
                inner join  [sis].[KitType] kittype on kit_old.KITTYPE  = kittype.Name and UPPER(TRIM(kittype.Name)) <> 'UNKNOWN'
            ) AS source (Kit_ID, KitType_ID)  
            ON (target.Kit_ID = source.Kit_ID 
                and target.KitType_ID = source.KitType_ID)
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID, KitType_ID)  
                VALUES (source.Kit_ID, source.KitType_ID)  
			WHEN NOT MATCHED BY SOURCE THEN
				DELETE
			OUTPUT 
                $ACTION,
                COALESCE(inserted.Kit_ID, deleted.Kit_ID) Kit_ID
                INTO @MERGE_RESULTS12;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS12 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS12 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Kit_ID
                                                FROM @MERGE_RESULTS12 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_Type_Relation Modified Rows');

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