CREATE PROCEDURE [sis].[KitComponent_Merge]  (@DEBUG BIT = 'FALSE')	
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


        -- Load table KitComponent

        DECLARE @MERGE_RESULTS2 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Number         VARCHAR(50) NOT NULL
			);
            
        BEGIN TRANSACTION;

        MERGE [sis].[KitComponent] AS target
            USING (
                select COMPONENT_NUMBER, max(PARTNAME) partname
                from [KIM].[SIS_KitBillOfMaterials]
                group by COMPONENT_NUMBER
            ) AS source (component_number, partname)
            ON (target.Number = source.component_number)
            WHEN MATCHED AND EXISTS(
                SELECT source.partname
                EXCEPT
                SELECT target.Name
                )THEN
            UPDATE SET Name = source.partname
            WHEN NOT MATCHED THEN
                INSERT (Number, Name)
                VALUES (source.component_number, source.partname)
            OUTPUT 
                $ACTION,
                COALESCE(inserted.Number, deleted.Number) Number
                INTO @MERGE_RESULTS2;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS2 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS2 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS2 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Number
                                                FROM @MERGE_RESULTS2 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'KitComponent Modified Rows');

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