﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200120
-- Modify Date: 20200205	fixed deadlock error
-- Description: Conditional load from STAGING MASMEDIA
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.MASMEDIA_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME_SIS sysname = 'SISWEB_OWNER_STAGING'
               ,@SCHEMANAME_EMP sysname = 'EMP_STAGING'
			   ,@TABLENAME  sysname = 'MASMEDIA';

		DECLARE @FULLTABLENAME_SIS   sysname = @SCHEMANAME_SIS + '.' + @TABLENAME
               ,@FULLTABLENAME_EMP   sysname = @SCHEMANAME_EMP + '.' + @TABLENAME
			   ,@CURRENT_VERSION BIGINT  = CHANGE_TRACKING_CURRENT_VERSION();

		DECLARE @LAST_SYNCHRONIZATION_VERSION_SIS BIGINT           = SISWEB_OWNER_STAGING._getLastSynchVersion (@FULLTABLENAME_SIS)
               ,@LAST_SYNCHRONIZATION_VERSION_EMP BIGINT           = EMP_STAGING._getLastSynchVersion (@FULLTABLENAME_EMP)
			   ,@RESULT                       BIT
			   ,@ROWCOUNT                     BIGINT
			   ,@MERGED_ROWS                  BIGINT           = 0
			   ,@SYSUTCDATETIME               DATETIME2(6)     = SYSUTCDATETIME()
			   ,@PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                    UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE              NVARCHAR(10)
									 ,MEDIANUMBER             VARCHAR(8) NOT NULL
									 ,MEDIATITLE              NVARCHAR(1536) NOT NULL
									 ,PUBLISHEDDATE           DATETIME2(0) NOT NULL
									 ,MEDIAUPDATEDDATE        DATETIME2(0) NULL
									 ,MEDIASOURCE             VARCHAR(1) NOT NULL
									 ,REVISIONNO              NUMERIC(38,10) NULL
									 ,SAFETYDOCUMENTINDICATOR VARCHAR(1) NOT NULL
									 ,BASEENGLISHMEDIANUMBER  VARCHAR(8) NOT NULL
									 ,NPRMEDIAREFERENCE       VARCHAR(8) NULL
									 ,PIPPSPNUMBER            VARCHAR(7) NULL
									 ,LANGUAGEINDICATOR       VARCHAR(2) NOT NULL
									 ,MEDIARID                NUMERIC(16,0) NULL
									 ,LASTMODIFIEDDATE        DATETIME2(6) NULL
									 ,MEDIAORIGIN             VARCHAR(2) NULL);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
		DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
        SELECT * INTO #DIFF_PRIMARY_KEYS FROM (
        SELECT CT.MEDIANUMBER,T.MEDIATITLE,T.PUBLISHEDDATE,T.MEDIAUPDATEDDATE,T.MEDIASOURCE,T.REVISIONNO,T.SAFETYDOCUMENTINDICATOR,T.BASEENGLISHMEDIANUMBER,
               T.NPRMEDIAREFERENCE,T.PIPPSPNUMBER,T.LANGUAGEINDICATOR,T.MEDIARID,T.LASTMODIFIEDDATE,T.MEDIAORIGIN,CT.SYS_CHANGE_OPERATION AS OPERATION, CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
        FROM [EMP_STAGING].[MASMEDIA] as T
        RIGHT JOIN CHANGETABLE(CHANGES [EMP_STAGING].[MASMEDIA],@LAST_SYNCHRONIZATION_VERSION_EMP) as CT
        ON T.MEDIANUMBER = CT.MEDIANUMBER
        WHERE CT.SYS_CHANGE_COLUMNS <> 0x000000000D000000 OR
            CT.SYS_CHANGE_COLUMNS IS NULL
        UNION
        SELECT CT.MEDIANUMBER,T.MEDIATITLE,T.PUBLISHEDDATE,T.MEDIAUPDATEDDATE,T.MEDIASOURCE,T.REVISIONNO,T.SAFETYDOCUMENTINDICATOR,T.BASEENGLISHMEDIANUMBER,
               T.NPRMEDIAREFERENCE,T.PIPPSPNUMBER,T.LANGUAGEINDICATOR,T.MEDIARID,T.LASTMODIFIEDDATE,T.MEDIAORIGIN,CT.SYS_CHANGE_OPERATION AS OPERATION, CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
        FROM [SISWEB_OWNER_STAGING].[MASMEDIA] as T
        RIGHT JOIN CHANGETABLE(CHANGES [SISWEB_OWNER_STAGING].[MASMEDIA],@LAST_SYNCHRONIZATION_VERSION_SIS) as CT
        ON T.MEDIANUMBER = CT.MEDIANUMBER
        WHERE CT.SYS_CHANGE_COLUMNS <> 0x000000000D000000 OR
            CT.SYS_CHANGE_COLUMNS IS NULL) AS DIFF;

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
			EXEC SISWEB_OWNER_STAGING._getFullOrDiffWithEMP @TABLENAME = @TABLENAME,@CURRENT_VERSION = @CURRENT_VERSION,@DEBUG = @DEBUG,@RESULT = @RESULT OUTPUT
			;

			IF @DEBUG = 'TRUE'
				PRINT FORMATMESSAGE('@RESULT=%s',IIF(@RESULT = 1,'TRUE','FALSE'));

			IF @RESULT = 'TRUE'
			BEGIN
				-- 6. Obtain the changes

				IF @DEBUG = 'TRUE'
					SELECT * FROM #DIFF_PRIMARY_KEYS AS DK;

				-- 7.a Delete if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'D';
				IF @ROWCOUNT > 0
				BEGIN
					DELETE FROM SISWEB_OWNER.MASMEDIA
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.MEDIANUMBER,DELETED.MEDIATITLE,DELETED.PUBLISHEDDATE,DELETED.MEDIAUPDATEDDATE,DELETED.MEDIASOURCE,DELETED.REVISIONNO,DELETED
					.SAFETYDOCUMENTINDICATOR,DELETED.BASEENGLISHMEDIANUMBER,DELETED.NPRMEDIAREFERENCE,DELETED.PIPPSPNUMBER,DELETED.LANGUAGEINDICATOR,DELETED.MEDIARID,DELETED.
					LASTMODIFIEDDATE,DELETED.MEDIAORIGIN
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.MEDIANUMBER = MASMEDIA.MEDIANUMBER AND 
							  DK.OPERATION = 'D'
					);

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Deleted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.b Insert if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'I';
				IF @ROWCOUNT > 0
				BEGIN
					INSERT INTO SISWEB_OWNER.MASMEDIA (MEDIANUMBER,MEDIATITLE,PUBLISHEDDATE,MEDIAUPDATEDDATE,MEDIASOURCE,REVISIONNO,SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER,
					NPRMEDIAREFERENCE,PIPPSPNUMBER,LANGUAGEINDICATOR,MEDIARID,LASTMODIFIEDDATE,MEDIAORIGIN) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.MEDIANUMBER,INSERTED.MEDIATITLE,INSERTED.PUBLISHEDDATE,INSERTED.MEDIAUPDATEDDATE,INSERTED.MEDIASOURCE,INSERTED.REVISIONNO,
					INSERTED.SAFETYDOCUMENTINDICATOR,INSERTED.BASEENGLISHMEDIANUMBER,INSERTED.NPRMEDIAREFERENCE,INSERTED.PIPPSPNUMBER,INSERTED.LANGUAGEINDICATOR,INSERTED.MEDIARID,
					INSERTED.LASTMODIFIEDDATE,INSERTED.MEDIAORIGIN
						   INTO @MERGE_RESULTS
						   SELECT MEDIANUMBER,MEDIATITLE,PUBLISHEDDATE,MEDIAUPDATEDDATE,MEDIASOURCE,REVISIONNO,SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER,NPRMEDIAREFERENCE,
						   PIPPSPNUMBER,LANGUAGEINDICATOR,MEDIARID,@SYSUTCDATETIME,MEDIAORIGIN
                           FROM #DIFF_PRIMARY_KEYS AS DK
                           WHERE DK.OPERATION = 'I'

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*)
				FROM #DIFF_PRIMARY_KEYS AS DK
				WHERE DK.OPERATION = 'U'
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER.MASMEDIA
					  SET MEDIATITLE = ST.MEDIATITLE,PUBLISHEDDATE = ST.PUBLISHEDDATE,MEDIAUPDATEDDATE = ST.MEDIAUPDATEDDATE,MEDIASOURCE = ST.MEDIASOURCE,REVISIONNO = ST.
					  REVISIONNO,SAFETYDOCUMENTINDICATOR = ST.SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER = ST.BASEENGLISHMEDIANUMBER,NPRMEDIAREFERENCE = ST.NPRMEDIAREFERENCE,
					  PIPPSPNUMBER = ST.PIPPSPNUMBER,LANGUAGEINDICATOR = ST.LANGUAGEINDICATOR,MEDIARID = ST.MEDIARID,LASTMODIFIEDDATE = @SYSUTCDATETIME,MEDIAORIGIN = ST.
					  MEDIAORIGIN
					OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.MEDIANUMBER,INSERTED.MEDIATITLE,INSERTED.PUBLISHEDDATE,INSERTED.MEDIAUPDATEDDATE,INSERTED.MEDIASOURCE,INSERTED.REVISIONNO,
					INSERTED.SAFETYDOCUMENTINDICATOR,INSERTED.BASEENGLISHMEDIANUMBER,INSERTED.NPRMEDIAREFERENCE,INSERTED.PIPPSPNUMBER,INSERTED.LANGUAGEINDICATOR,INSERTED.MEDIARID,
					INSERTED.LASTMODIFIEDDATE,INSERTED.MEDIAORIGIN
						   INTO @MERGE_RESULTS
					FROM #DIFF_PRIMARY_KEYS AS ST
						 JOIN SISWEB_OWNER.MASMEDIA AS TT ON ST.MEDIANUMBER = TT.MEDIANUMBER AND
                         ST.OPERATION = 'U'

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 8. Store current version to be used the next time
				IF @DEBUG = 'TRUE'
					SELECT * FROM @MERGE_RESULTS AS MR;

                EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME_SIS,@CURRENT_VERSION;
                EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME_EMP,@CURRENT_VERSION;

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.MEDIANUMBER,MR.MEDIATITLE,MR.PUBLISHEDDATE,MR.MEDIAUPDATEDDATE,MR.MEDIASOURCE,MR.REVISIONNO,MR.SAFETYDOCUMENTINDICATOR,MR.BASEENGLISHMEDIANUMBER,
						MR.NPRMEDIAREFERENCE,MR.PIPPSPNUMBER,MR.LANGUAGEINDICATOR,MR.MEDIARID,MR.LASTMODIFIEDDATE,MR.MEDIAORIGIN
						FROM @MERGE_RESULTS AS MR FOR JSON AUTO
					) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
				),'Modified Rows');
				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
			END;
		END;

		/* to be done: handle full load with MERGE */
		IF @FORCE_LOAD = 'TRUE'
		--   OR @MODIFIED_ROWS_PERCENTAGE BETWEEN-0.10 AND 0.10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: Force Load = TRUE';
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @FORCE_LOAD;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.MASMEDIA tgt
			USING ( SELECT MEDIANUMBER,MEDIATITLE,PUBLISHEDDATE,MEDIAUPDATEDDATE,MEDIASOURCE,REVISIONNO,SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER,
                           NPRMEDIAREFERENCE,PIPPSPNUMBER,LANGUAGEINDICATOR,MEDIARID,LASTMODIFIEDDATE,MEDIAORIGIN
			        FROM [EMP_STAGING].[MASMEDIA]
			        UNION
                    SELECT MEDIANUMBER,MEDIATITLE,PUBLISHEDDATE,MEDIAUPDATEDDATE,MEDIASOURCE,REVISIONNO,SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER,
                        NPRMEDIAREFERENCE,PIPPSPNUMBER,LANGUAGEINDICATOR,MEDIARID,LASTMODIFIEDDATE,MEDIAORIGIN
                    FROM [SISWEB_OWNER_STAGING].[MASMEDIA]
                ) src
			ON src.MEDIANUMBER = tgt.MEDIANUMBER
			WHEN MATCHED AND EXISTS
			(
				SELECT src.MEDIATITLE,src.PUBLISHEDDATE,src.MEDIAUPDATEDDATE,src.MEDIASOURCE,src.REVISIONNO,src.SAFETYDOCUMENTINDICATOR,src.BASEENGLISHMEDIANUMBER,src.
				NPRMEDIAREFERENCE,src.PIPPSPNUMBER,src.LANGUAGEINDICATOR,src.MEDIARID,src.MEDIAORIGIN
				EXCEPT
				SELECT tgt.MEDIATITLE,tgt.PUBLISHEDDATE,tgt.MEDIAUPDATEDDATE,tgt.MEDIASOURCE,tgt.REVISIONNO,tgt.SAFETYDOCUMENTINDICATOR,tgt.BASEENGLISHMEDIANUMBER,tgt.
				NPRMEDIAREFERENCE,tgt.PIPPSPNUMBER,tgt.LANGUAGEINDICATOR,tgt.MEDIARID,tgt.MEDIAORIGIN
			)
				  THEN UPDATE SET tgt.MEDIATITLE = src.MEDIATITLE,tgt.PUBLISHEDDATE = src.PUBLISHEDDATE,tgt.MEDIAUPDATEDDATE = src.MEDIAUPDATEDDATE,tgt.MEDIASOURCE = src.
				  MEDIASOURCE,tgt.REVISIONNO = src.REVISIONNO,tgt.SAFETYDOCUMENTINDICATOR = src.SAFETYDOCUMENTINDICATOR,tgt.BASEENGLISHMEDIANUMBER = src.BASEENGLISHMEDIANUMBER,tgt
				  .NPRMEDIAREFERENCE = src.NPRMEDIAREFERENCE,tgt.PIPPSPNUMBER = src.PIPPSPNUMBER,tgt.LANGUAGEINDICATOR = src.LANGUAGEINDICATOR,tgt.MEDIARID = src.MEDIARID,tgt.
				  LASTMODIFIEDDATE = @SYSUTCDATETIME,tgt.MEDIAORIGIN = src.MEDIAORIGIN
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(MEDIANUMBER,MEDIATITLE,PUBLISHEDDATE,MEDIAUPDATEDDATE,MEDIASOURCE,REVISIONNO,SAFETYDOCUMENTINDICATOR,BASEENGLISHMEDIANUMBER,NPRMEDIAREFERENCE,PIPPSPNUMBER,
				  LANGUAGEINDICATOR,MEDIARID,LASTMODIFIEDDATE,MEDIAORIGIN)
				  VALUES (src.MEDIANUMBER,src.MEDIATITLE,src.PUBLISHEDDATE,src.MEDIAUPDATEDDATE,src.MEDIASOURCE,src.REVISIONNO,src.SAFETYDOCUMENTINDICATOR,src.
				  BASEENGLISHMEDIANUMBER,src.NPRMEDIAREFERENCE,src.PIPPSPNUMBER,src.LANGUAGEINDICATOR,src.MEDIARID,@SYSUTCDATETIME,src.MEDIAORIGIN) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.MEDIANUMBER,deleted.MEDIANUMBER) MEDIANUMBER,COALESCE(inserted.MEDIATITLE,deleted.MEDIATITLE) MEDIATITLE,COALESCE(inserted.
			PUBLISHEDDATE,deleted.PUBLISHEDDATE) PUBLISHEDDATE,COALESCE(inserted.MEDIAUPDATEDDATE,deleted.MEDIAUPDATEDDATE) MEDIAUPDATEDDATE,COALESCE(inserted.MEDIASOURCE,deleted.
			MEDIASOURCE) MEDIASOURCE,COALESCE(inserted.REVISIONNO,deleted.REVISIONNO) REVISIONNO,COALESCE(inserted.SAFETYDOCUMENTINDICATOR,deleted.SAFETYDOCUMENTINDICATOR)
			SAFETYDOCUMENTINDICATOR,COALESCE(inserted.BASEENGLISHMEDIANUMBER,deleted.BASEENGLISHMEDIANUMBER) BASEENGLISHMEDIANUMBER,COALESCE(inserted.NPRMEDIAREFERENCE,deleted.
			NPRMEDIAREFERENCE) NPRMEDIAREFERENCE,COALESCE(inserted.PIPPSPNUMBER,deleted.PIPPSPNUMBER) PIPPSPNUMBER,COALESCE(inserted.LANGUAGEINDICATOR,deleted.LANGUAGEINDICATOR)
			LANGUAGEINDICATOR,COALESCE(inserted.MEDIARID,deleted.MEDIARID) MEDIARID,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE,COALESCE(inserted
			.MEDIAORIGIN,deleted.MEDIAORIGIN) MEDIAORIGIN
				   INTO @MERGE_RESULTS;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;

            EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME_SIS,@CURRENT_VERSION;
            EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME_EMP,@CURRENT_VERSION;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.MEDIANUMBER,MR.MEDIATITLE,MR.PUBLISHEDDATE,MR.MEDIAUPDATEDDATE,MR.MEDIASOURCE,MR.REVISIONNO,MR.SAFETYDOCUMENTINDICATOR,MR.
					BASEENGLISHMEDIANUMBER,MR.NPRMEDIAREFERENCE,MR.PIPPSPNUMBER,MR.LANGUAGEINDICATOR,MR.MEDIARID,MR.LASTMODIFIEDDATE,MR.MEDIAORIGIN
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		COMMIT;

								UPDATE STATISTICS SISWEB_OWNER.MASMEDIA WITH FULLSCAN;

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
GO

