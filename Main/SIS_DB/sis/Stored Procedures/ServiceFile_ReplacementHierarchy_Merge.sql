-- =============================================
-- Author:      Sachin Poolamannil (+Ramesh Ramalingam)
-- Create Date: 20201030
-- Description: Merge SISWEB_OWNER.LNKFILEREPLACEMENTHIERARCHY to sis.ServiceFile_ReplacementHierarchy
-- =============================================
CREATE PROCEDURE [sis].[ServiceFile_ReplacementHierarchy_Merge]
    (@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MERGED_ROWS                   INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);
        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE                 NVARCHAR(10),
             ServiceFile_ID             INT         NOT NULL,
             Replacing_ServiceFile_ID   INT         NOT NULL,
             Sequence_No                INT         NOT NULL);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

            /* MERGE command */
            MERGE INTO sis.ServiceFile_ReplacementHierarchy tgt
            USING (select l.FILERID,l.LASTMODIFIEDDATE,l.REPLACEDBYFILERID,l.SEQNO
			FROM SISWEB_OWNER.LNKFILEREPLACEMENTHIERARCHY l
			JOIN SISWEB_OWNER.MASFILEPROPERTIES m
			ON l.FILERID=m.FILERID) src
            ON
               src.FILERID = tgt.ServiceFile_ID AND
               src.REPLACEDBYFILERID = tgt.Replacing_ServiceFile_ID
               WHEN MATCHED AND EXISTS(SELECT src.SEQNO
                                        EXCEPT
                                        SELECT  tgt.Sequence_No)
                  THEN UPDATE SET tgt.Sequence_No = src.SEQNO
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT( ServiceFile_ID
                          ,Replacing_ServiceFile_ID
                          ,Sequence_No)
                  VALUES
                ( src.[FILERID]
                 ,src.[REPLACEDBYFILERID]
                 ,src.[SEQNO]
                ) 
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.ServiceFile_ID,deleted.ServiceFile_ID) ServiceFile_ID
                  ,COALESCE(inserted.Replacing_ServiceFile_ID,deleted.Replacing_ServiceFile_ID) Replacing_ServiceFile_ID
                  ,COALESCE(inserted.Sequence_No,deleted.Sequence_No) Sequence_No
                   INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.ServiceFile_ID
                                                                ,MR.Replacing_ServiceFile_ID
                                                                ,MR.Sequence_No
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
            COMMIT;
             Update STATISTICS sis.ServiceFile_ReplacementHierarchy with fullscan 
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
               ,@ERRORLINE    INT            = ERROR_LINE()
               ,@ERRORNUM     INT            = ERROR_NUMBER();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
    END CATCH;
END;

