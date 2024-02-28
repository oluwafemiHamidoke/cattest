CREATE PROCEDURE [sis].[Kit_ImageIdentifier_Merge]  (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@ProcName                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@ProcessID                     UNIQUEIDENTIFIER = NEWID()

        -- Load Kit_ImageIdentifier Table
        DECLARE @MERGE_RESULTS13 TABLE (ACTIONTYPE NVARCHAR(10),[Kit_ID]	[int]);

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

        BEGIN TRANSACTION;
        
        MERGE [sis].[Kit_ImageIdentifier] AS target
            USING (
				select  kit.Kit_ID, CM_NUMBER
				from 		[KIM].[SIS_CAL] cal
				inner join  [KIM].[SIS_KitNumbers] kitNumber 	on kitNumber.KITNUMBER = cal.PART_NUMBER
				inner join 	[sis].[kit] kit 			            on kit.Number=kitNumber.KITNUMBER
            ) AS source (Kit_ID, CM_NUMBER)
            ON
				(target.[Kit_ID] = source.[Kit_ID] 
			AND target.[CM_Number] = source.CM_NUMBER)
			WHEN NOT MATCHED BY TARGET THEN
				INSERT ([Kit_ID], [CM_Number])  VALUES (source.[Kit_ID], source.CM_NUMBER)
			WHEN NOT MATCHED BY SOURCE THEN
				DELETE
			OUTPUT 
				$ACTION,
			COALESCE(inserted.[Kit_ID], deleted.[Kit_ID]) [Kit_ID]
				INTO @MERGE_RESULTS13;
			
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS13 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS13 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Kit_ID
                                                FROM @MERGE_RESULTS13 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_ImageIdentifier Modified Rows');

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