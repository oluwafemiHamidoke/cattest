-- =============================================
-- Author:      Sooraj Parameswaran
-- Create Date: 20210909
-- Modify Date: 20210909 - as per Work Item - https://sis-cat-com.visualstudio.com/sis2-ui/_sprints/backlog/sis2-ui%20Team/sis2-ui/Sprint%2071?workitem=15099
-- Description: Merge SISWEB_OWNER.LNKFILESEARCHCRITERIA to sis.ServiceFile_SearchCriteria
-- =============================================
CREATE PROCEDURE [sis].[ServiceFile_SearchCriteria_Merge](@DEBUG BIT = 'FALSE')
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @RELOADED_ROWS                 INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);

        BEGIN TRANSACTION;

        EXEC sis.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

        -- Updating the existing ones by deleting and re-inserting data
        -- New rows are also inserted in this process
        --Identify Deleted Records From Source
	    drop table if exists #Modified

		SELECT  A.ServiceFile_ID
		INTO    #Modified
		FROM    (
		            Select ServiceFile_ID,
		                InfoType_ID,
                        Search_Type,
                        ISNULL(Value, 'X') as Value,
                        ISNULL(Search_Value, 'X') as Search_Value,
                        ISNULL(Begin_Range, 0) AS Begin_Range,
                        ISNULL(End_Range, 0) AS End_Range,
                        ISNULL(Num_Data, 0) Num_Data
                    From sis.ServiceFile_SearchCriteria
                ) A
		LEFT OUTER JOIN (
		                    SELECT l.FILERID as ServiceFile_ID,
		                            l.INFOTYPEID as InfoType_ID,
                                    l.SEARCHRECORDTYPE as Search_Type,
                                    ISNULL(l.CHARDATA, 'X') as Value,
                                    ISNULL(l.CHARDATA, 'X') as Search_Value,
                                    ISNULL(l.BEGRANGE, 0) as Begin_Range,
                                    ISNULL(l.ENDRANGE, 0) as End_Range,
                                    ISNULL(l.NUMDATA, 0) as Num_Data
							From SISWEB_OWNER.LNKFILESEARCHCRITERIA l
						    JOIN SISWEB_OWNER.MASFILEPROPERTIES m ON l.FILERID = m.FILERID
						) B
        ON (
                A.ServiceFile_ID = B.ServiceFile_ID
                AND A.InfoType_ID = B.InfoType_ID
                AND A.Search_Type = B.Search_Type
                AND A.Value = B.Value
                AND A.Search_Value = B.Search_Value
                AND A.Begin_Range = B.Begin_Range
                AND A.End_Range = B.End_Range
                AND A.Num_Data = B.Num_Data
            )
		WHERE B.ServiceFile_ID IS NULL

        INSERT INTO  #Modified
		SELECT A.ServiceFile_ID
		FROM (
		        SELECT l.FILERID as ServiceFile_ID,
		            l.INFOTYPEID as InfoType_ID,
                    l.SEARCHRECORDTYPE as Search_Type,
                    ISNULL(l.CHARDATA, 'X') as Value,
                    ISNULL(l.CHARDATA, 'X') as Search_Value,
                    ISNULL(l.BEGRANGE, 0) as Begin_Range,
                    ISNULL(l.ENDRANGE, 0) as End_Range,
                    ISNULL(l.NUMDATA, 0) as Num_Data
                From SISWEB_OWNER.LNKFILESEARCHCRITERIA l
				JOIN SISWEB_OWNER.MASFILEPROPERTIES m ON l.FILERID = m.FILERID
		    ) A
		LEFT JOIN   (
		                Select ServiceFile_ID,
		                    InfoType_ID,
                            Search_Type,
                            ISNULL(Value, 'X') as Value,
                            ISNULL(Search_Value, 'X') as Search_Value,
                            ISNULL(Begin_Range, 0) AS Begin_Range,
                            ISNULL(End_Range, 0) AS End_Range,
                            ISNULL(Num_Data, 0) Num_Data
                        From sis.ServiceFile_SearchCriteria
                    ) B
        ON (
                A.ServiceFile_ID = B.ServiceFile_ID
                AND A.InfoType_ID = B.InfoType_ID
                AND A.Search_Type = B.Search_Type
                AND A.Value = B.Value
                AND A.Search_Value = B.Search_Value
                AND A.Begin_Range = B.Begin_Range
                AND A.End_Range = B.End_Range
                AND A.Num_Data = B.Num_Data
            )
		WHERE B.ServiceFile_ID IS NULL

		--all the rows for the updated ServiceFile_ID are deleted.

		DELETE FROM sis.ServiceFile_SearchCriteria
		Where  ServiceFile_ID in (Select ServiceFile_ID From #Modified)

        EXEC sis.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Deleted Rows',@DATAVALUE = @@ROWCOUNT;

	    -- all the rows for the updated ServiceFile_ID are inserted again.
		Insert Into sis.ServiceFile_SearchCriteria
		([ServiceFile_ID], [InfoType_ID], [Search_Type], [Value], [Search_Value], [Begin_Range], [End_Range], [Num_Data])
		Select l.FILERID, l.INFOTYPEID, l.SEARCHRECORDTYPE, l.CHARDATA, l.CHARDATA, l.BEGRANGE, l.ENDRANGE, l.NUMDATA
		From SISWEB_OWNER.LNKFILESEARCHCRITERIA l
        JOIN SISWEB_OWNER.MASFILEPROPERTIES m ON l.FILERID = m.FILERID
		Where l.FILERID in (select ServiceFile_ID from #Modified)

        EXEC sis.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Inserted/Updated Rows',@DATAVALUE = @@ROWCOUNT;

        COMMIT;

	    drop table if exists #Modified

        EXEC sis.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
               ,@ERRORLINE    INT            = ERROR_LINE()
               ,@ERRORNUM     INT            = ERROR_NUMBER();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
        EXEC sis.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
    END CATCH;
END;
GO

