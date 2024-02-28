-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20191218 - Davide: added @DEBUG parameter and [LASTMODIFIEDDATE] column
-- Description: Conditional load from STAGING SUPERSESSIONCHAINS
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.SUPERSESSIONCHAINS_Merge
	(@FORCE_LOAD BIT = 'FALSE'
	,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
			   ,@MERGED_ROWS                   INT              = 0
			   ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@SYSUTCDATETIME                DATETIME2(6)     = SYSUTCDATETIME()
               ,@DEFAULT_ORGCODE			  VARCHAR(12) 	    = SISWEB_OWNER_STAGING._getDefaultORGCODE();;


        DECLARE @MERGE_RESULTS TABLE
			(ACTIONTYPE               NVARCHAR(10),
			[PARTNUMBER]              VARCHAR (40)   NOT NULL,
            [ORGCODE]                 VARCHAR (12)   NOT NULL,
            [LASTPARTNUMBER]          VARCHAR (40)   NOT NULL,
            [LASTORGCODE]             VARCHAR (12)   NOT NULL,
            [CHAIN]                   VARCHAR (4000) NOT NULL,
            [isExpandedMiningProduct] BIT            NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='SUPERSESSIONCHAINS', @SISWEB_OWNER_STAGING_TABLE = 'SUPERSESSIONCHAINS', @EMP_STAGING_TABLE = 'SUPERSESSIONCHAINS';
		END;

		IF
		   @FORCE_LOAD = 1
		   OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.SUPERSESSIONCHAINS tgt
            USING (
            SELECT PARTNUMBER,ORGCODE,LASTPARTNUMBER,LASTORGCODE,CHAIN, 1 AS isExpandedMiningProduct
            FROM EMP_STAGING.SUPERSESSIONCHAINS
            UNION ALL
            SELECT PARTNUMBER,@DEFAULT_ORGCODE AS [ORGCODE],LASTPARTNUMBER,@DEFAULT_ORGCODE AS [LASTORGCODE],CHAIN, 0 AS isExpandedMiningProduct
            FROM SISWEB_OWNER_STAGING.SUPERSESSIONCHAINS) src
			ON
			   src.PARTNUMBER       = tgt.PARTNUMBER AND
               src.ORGCODE          = tgt.ORGCODE AND
			   src.LASTPARTNUMBER   = tgt.LASTPARTNUMBER AND
               src.LASTORGCODE      = tgt.LASTORGCODE AND
			   src.CHAIN            = tgt.CHAIN AND
			   src.isExpandedMiningProduct = tgt.isExpandedMiningProduct
			/* Can't happen */
			--WHEN MATCHED AND EXISTS(SELECT src.KITPARTNAME
			--						EXCEPT
			--						SELECT tgt.KITPARTNAME)
			--  THEN UPDATE SET tgt.KITPARTNAME = src.KITPARTNAME,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
				WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(PARTNUMBER
			            ,ORGCODE
						,LASTPARTNUMBER
			            ,LASTORGCODE
						,CHAIN
                        ,isExpandedMiningProduct
						,LASTMODIFIEDDATE)
				  VALUES
				(src.PARTNUMBER
			    ,src.ORGCODE
				,src.LASTPARTNUMBER
                ,src.LASTORGCODE
				,src.CHAIN
			    ,src.isExpandedMiningProduct
				,@SYSUTCDATETIME
				)
				WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION
				  ,COALESCE(inserted.PARTNUMBER,deleted.PARTNUMBER) PARTNUMBER
                  ,COALESCE(inserted.ORGCODE,deleted.ORGCODE) ORGCODE
				  ,COALESCE(inserted.LASTPARTNUMBER,deleted.LASTPARTNUMBER) LASTPARTNUMBER
                  ,COALESCE(inserted.LASTORGCODE,deleted.LASTORGCODE) LASTORGCODE
				  ,COALESCE(inserted.CHAIN,deleted.CHAIN) CHAIN
                  ,COALESCE(inserted.isExpandedMiningProduct,deleted.isExpandedMiningProduct) isExpandedMiningProduct
				   INTO @MERGE_RESULTS;
			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
														,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
														,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
														,(SELECT MR.ACTIONTYPE
																,MR.PARTNUMBER
                                                                ,MR.ORGCODE
																,MR.LASTPARTNUMBER
                                                                ,MR.LASTORGCODE
																,MR.CHAIN
                                                                ,MR.isExpandedMiningProduct FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS                  Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		ELSE
		BEGIN
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
		END;
		COMMIT;

				UPDATE STATISTICS SISWEB_OWNER.SUPERSESSIONCHAINS WITH FULLSCAN;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE();

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = 'LINE ' + CAST(@ERRORLINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
	END CATCH;
END;
GO
