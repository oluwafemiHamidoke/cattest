CREATE PROCEDURE [sis_stage].[IEPart_Effective_Date_Load]
AS
	BEGIN
		 SET NOCOUNT ON;
		 BEGIN TRY
			DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@ProcessID UNIQUEIDENTIFIER = NEWID()
                   ,@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE()
			       ,@LOGMESSAGEDESC  VARCHAR(MAX);

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

			--Load IE_InfoType_Relation
			INSERT INTO sis_stage.IEPart_Effective_Date (
				IEPart_ID,[Media_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID], [DayEffective], [DayNotEffective]
				)
            select
                iep.IEPart_ID,m.[Media_ID], snp.[SerialNumberPrefix_ID], snr.[SerialNumberRange_ID], ld.DAYEFFECTIVE, MAX(ld.DAYNOTEFFECTIVE) as DAYNOTEFFECTIVE
            from SISWEB_OWNER.LNKIEEFFECTIVEDATES ld
                     inner join sis_stage.IEPart iep on iep.IE_Control_Number = ld.CONTROLNUMBER
                     inner join sis_stage.SerialNumberPrefix snp on snp.Serial_Number_Prefix = ld.PREFIX
                     inner join sis_stage.SerialNumberRange snr on snr.Start_Serial_Number = ld.BEGINRANGE and snr.End_Serial_Number = ld.ENDRANGE
                     inner join sis_stage.Media m on m.Media_Number = ld.MEDIANUMBER
            group by iep.IEPart_ID,m.[Media_ID], snp.[SerialNumberPrefix_ID], snr.[SerialNumberRange_ID], ld.DAYEFFECTIVE;
--select 'IE' Table_Name, @@RowCount Record_Count
            EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Effective_Date Load', @DATAVALUE = @@ROWCOUNT;

			--Load Diff table
			INSERT INTO sis_stage.IEPart_Effective_Date_Diff (
				Operation, [IEPart_ID], [Media_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID], [DayEffective], [DayNotEffective]
				)
					SELECT distinct 'Insert' AS Operation,
					s.IEPart_ID, s.Media_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.DayEffective, s.DayNotEffective
					FROM sis_stage.IEPart_Effective_Date as s
						LEFT OUTER JOIN sis.IEPart_Effective_Date as x
							ON
							s.IEPart_ID				=	x.IEPart_ID and
							s.Media_ID				=	x.Media_ID and
							s.SerialNumberPrefix_ID	=	x.SerialNumberPrefix_ID and
							s.SerialNumberRange_ID	=	x.SerialNumberRange_ID	and
							s.DayEffective			=	x.DayEffective
				   WHERE x.IEPart_ID IS NULL --Inserted
				   UNION ALL
				   SELECT distinct 'Delete' AS Operation, tgt.IEPart_ID, tgt.Media_ID, tgt.SerialNumberPrefix_ID, tgt.SerialNumberRange_ID, tgt.DayEffective, tgt.DayNotEffective
				   FROM sis.IEPart_Effective_Date AS tgt
						LEFT OUTER JOIN sis_stage.IEPart_Effective_Date AS src
						ON
							tgt.IEPart_ID				=	src.IEPart_ID and
							tgt.Media_ID				=	src.Media_ID and
							tgt.SerialNumberPrefix_ID	=	src.SerialNumberPrefix_ID and
							tgt.SerialNumberRange_ID	=	src.SerialNumberRange_ID	and
							tgt.DayEffective			=	src.DayEffective
				   WHERE src.IEPart_ID IS NULL --Deleted
				   --Updates cannot occur because there all fields are part of the pkey.  Only insert & delete.

			--Diff Load
            EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Effective_Date_Diff Load', @DATAVALUE = @@ROWCOUNT;

            EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

		 END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
				   ,@ERROELINE    INT            = ERROR_LINE();

			SET @LOGMESSAGEDESC = 'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGEDESC,@DATAVALUE = NULL;

		END CATCH;
	END