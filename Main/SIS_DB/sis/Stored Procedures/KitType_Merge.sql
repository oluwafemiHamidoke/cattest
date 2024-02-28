CREATE PROCEDURE [sis].[KitType_Merge]	 (@DEBUG BIT = 'FALSE')
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


       -- Load KitType
        DECLARE @MERGE_RESULTS5 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Name         VARCHAR(50) NOT NULL
			);
            
        BEGIN TRANSACTION;

        MERGE [sis].[KitType] AS target
            USING (
                select  KITTYPE kittype
                from        [KIM].[SIS_KitNumbers]
                where       KITTYPE is not null and UPPER(TRIM(KITTYPE)) <> 'UNKNOWN'
                group by    KITTYPE
            ) AS source (kittype)
            ON (target.Name = source.kittype)
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Name)
                VALUES (source.kittype)
            OUTPUT 
                $ACTION,
                COALESCE(inserted.Name, deleted.Name) KitType_Name
                INTO @MERGE_RESULTS5;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS5 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS5 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS5 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Name
                                                FROM @MERGE_RESULTS5 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'KitType Modified Rows');

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