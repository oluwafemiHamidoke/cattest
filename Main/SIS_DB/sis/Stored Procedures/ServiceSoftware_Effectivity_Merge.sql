CREATE PROCEDURE [sis].[ServiceSoftware_Effectivity_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY

        DECLARE @MERGED_ROWS                   INT              = 0
            ,@LOGMESSAGE                    VARCHAR(MAX);

        Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        Declare @ProcessID uniqueidentifier = NewID()

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        DECLARE @MERGE_RESULTS TABLE
        (ACTIONTYPE         NVARCHAR(10)
        ,Number         VARCHAR(50) NOT NULL 
        );

        MERGE [sis].[ServiceSoftware_Effectivity] AS tgt
            USING [sis_stage].[ServiceSoftware_Effectivity] AS src
        ON (src.ServiceSoftware_Effectivity_ID = tgt.ServiceSoftware_Effectivity_ID)
        WHEN MATCHED AND EXISTS
            (
           SELECT src.SerialNumberPrefix_ID, src.Start_Serial_Number, src.End_Serial_Number, src.Application_ID, src.Component_ID, src.Location_Code, src.Part_Number, src.Version, src.Product_Link_Config
            EXCEPT
            SELECT tgt.SerialNumberPrefix_ID,tgt.Start_Serial_Number, tgt.End_Serial_Number, tgt.Application_ID, tgt.Component_ID, tgt.Location_Code, tgt.Part_Number, tgt.Version, tgt.Product_Link_Config
            )
            THEN UPDATE SET 
                tgt.SerialNumberPrefix_ID = src.SerialNumberPrefix_ID, tgt.Start_Serial_Number = src.Start_Serial_Number, tgt.End_Serial_Number = src.End_Serial_Number, tgt.Application_ID = src.Application_ID, tgt.Component_ID = src.Component_ID, tgt.Location_Code = src.Location_Code,
                tgt.Part_Number = src.Part_Number, tgt.Version = src.Version, tgt.Product_Link_Config = src.Product_Link_Config
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ServiceSoftware_Effectivity_ID, SerialNumberPrefix_ID, Start_Serial_Number, End_Serial_Number, Application_ID, Component_ID, Location_Code, Part_Number, Version, Product_Link_Config)
            VALUES (src.ServiceSoftware_Effectivity_ID, src.SerialNumberPrefix_ID, src.Start_Serial_Number, src.End_Serial_Number, src.Application_ID, src.Component_ID, src.Location_Code, src.Part_Number, src.Version, src.Product_Link_Config)
        OUTPUT $ACTION,
            COALESCE(inserted.ServiceSoftware_Effectivity_ID, deleted.ServiceSoftware_Effectivity_ID) Number
        INTO @MERGE_RESULTS;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.Number
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                                            ,WITHOUT_ARRAY_WRAPPER),'ServiceSoftware_Effectivity Modified Rows');
        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS sis.ServiceSoftware_Effectivity with fullscan

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END
