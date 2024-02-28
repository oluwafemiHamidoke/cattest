-- =============================================
-- Create Date: 12072022
-- Description: Merge PROCEDURE for below CDS table
-- CDS_BlobDetails
-- CDS_CIDCodeDetails
-- CDS_FMICodeDetails
-- CDS_MIDCodeDetails
-- CDS_TroubleshootingInfo
-- =============================================
CREATE PROCEDURE [sis].[CDS_data_Merge] (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

	BEGIN TRY
		DECLARE @MERGED_ROWS INT = 0
			,@LOGMESSAGE VARCHAR(MAX)
			,@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@ProcessID UNIQUEIDENTIFIER = NEWID()
			,@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution started'
			,@DATAVALUE = NULL;

		DECLARE @MERGE_RESULTS TABLE (
		    ACTIONTYPE     NVARCHAR(10),
		    ID             INT  NOT NULL
        );

		BEGIN TRANSACTION;

				-- TroubleshootingIllustrationDetails
				MERGE sis.TroubleshootingIllustrationDetails AS x
				USING sis_stage.TroubleshootingIllustrationDetails AS s
				ON (
				    x.TroubleshootingIllustrationDetails_ID = s.TroubleshootingIllustrationDetails_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.TroubleshootingIllustrationDetails_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.BlobRefID, s.BlobType, s.Media_ID
                		EXCEPT
				    SELECT x.TroubleshootingIllustrationDetails_ID, x.SerialNumberPrefix_ID, x.SerialNumberRange_ID, x.BlobRefID, x.BlobType, x.Media_ID
                		)
                    		THEN
                    		UPDATE SET x.TroubleshootingIllustrationDetails_ID = s.TroubleshootingIllustrationDetails_ID,
                    	    	x.SerialNumberPrefix_ID = s.SerialNumberPrefix_ID,
                    	    	x.SerialNumberRange_ID = s.SerialNumberRange_ID,
                    	    	x.BlobRefID = s.BlobRefID,
                    	    	x.BlobType = s.BlobType,
				x.Media_ID = s.Media_ID
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingIllustrationDetails_ID,
						    SerialNumberPrefix_ID,
						    SerialNumberRange_ID,
						    BlobRefID,
						    BlobType,
						    Media_ID)
						VALUES ( s.TroubleshootingIllustrationDetails_ID,
						    s.SerialNumberPrefix_ID,
						    s.SerialNumberRange_ID,
						    s.BlobRefID,
						    s.BlobType,
						    s.Media_ID)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingIllustrationDetails_ID, deleted.TroubleshootingIllustrationDetails_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingIllustrationDetails Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;


				-- CIDCodeDetails
				MERGE sis.CIDCodeDetails AS x
				USING sis_stage.CIDCodeDetails AS s
				ON (
				    x.CIDCodeDetails_ID = s.CIDCodeDetails_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.CIDCodeDetails_ID, s.CIDCode, s.CIDType, s.CIDDescription
                	EXCEPT
				    SELECT x.CIDCodeDetails_ID, x.CIDCode, x.CIDType, x.CIDDescription
                	)
                    THEN
                    	UPDATE SET x.CIDCodeDetails_ID = s.CIDCodeDetails_ID,
                    	    x.CIDCode = s.CIDCode,
                    	    x.CIDType = s.CIDType,
                    	    x.CIDDescription = s.CIDDescription
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( CIDCodeDetails_ID, CIDCode, CIDType, CIDDescription )
						VALUES ( s.CIDCodeDetails_ID, s.CIDCode, s.CIDType, s.CIDDescription )
				OUTPUT $ACTION,
                	COALESCE(inserted.CIDCodeDetails_ID, deleted.CIDCodeDetails_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'CIDCodeDetails Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;


				-- FMICodeDetails
				MERGE sis.FMICodeDetails AS x
				USING sis_stage.FMICodeDetails AS s
				ON (
				    x.FMICodeDetails_ID = s.FMICodeDetails_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.FMICodeDetails_ID, s.FMICode, s.FMIType, s.FMIDescription
                	EXCEPT
				    SELECT x.FMICodeDetails_ID, x.FMICode, x.FMIType, x.FMIDescription
                	)
                    THEN
                    	UPDATE SET x.FMICodeDetails_ID = s.FMICodeDetails_ID,
                    	    x.FMICode = s.FMICode,
                    	    x.FMIType = s.FMIType,
                    	    x.FMIDescription = s.FMIDescription
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( FMICodeDetails_ID, FMICode, FMIType, FMIDescription )
						VALUES ( s.FMICodeDetails_ID, s.FMICode, s.FMIType, s.FMIDescription )
				OUTPUT $ACTION,
                	COALESCE(inserted.FMICodeDetails_ID, deleted.FMICodeDetails_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'FMICodeDetails Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;


				-- MIDCodeDetails
				MERGE sis.MIDCodeDetails AS x
				USING sis_stage.MIDCodeDetails AS s
				ON (
				    x.MIDCodeDetails_ID = s.MIDCodeDetails_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.MIDCodeDetails_ID, s.MIDCode, s.MIDType, s.MIDDescription
                	EXCEPT
				    SELECT x.MIDCodeDetails_ID, x.MIDCode, x.MIDType, x.MIDDescription
                	)
                    THEN
                    	UPDATE SET x.MIDCodeDetails_ID = s.MIDCodeDetails_ID,
                    	    x.MIDCode = s.MIDCode,
                    	    x.MIDType = s.MIDType,
                    	    x.MIDDescription = s.MIDDescription
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( MIDCodeDetails_ID, MIDCode, MIDType, MIDDescription )
						VALUES ( s.MIDCodeDetails_ID, s.MIDCode, s.MIDType, s.MIDDescription )
				OUTPUT $ACTION,
                	COALESCE(inserted.MIDCodeDetails_ID, deleted.MIDCodeDetails_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'MIDCodeDetails Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

				-- ConfigurationInfo

				MERGE sis.ConfigurationInfo AS x
				USING sis_stage.ConfigurationInfo AS s
				ON (
				    x.Configuration_ID = s.Configuration_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.Configuration_ID, s.Name, s.UpdatedBy, s.UpdatedTime, s.CreatedBy, s.CreatedTime, s.IsDeleted, s.Abbreviation
                	EXCEPT
				    SELECT x.Configuration_ID, x.Name, x.UpdatedBy, x.UpdatedTime, x.CreatedBy, x.CreatedTime, x.IsDeleted, x.Abbreviation
                	)
                    THEN
                    	UPDATE SET 
						x.Configuration_ID=s.Configuration_ID, 
						x.Name=s.Name, 
						x.UpdatedBy=s.UpdatedBy, 
						x.UpdatedTime=s.UpdatedTime, 
						x.CreatedBy=s.CreatedBy, 
						x.CreatedTime=s.CreatedTime, 
						x.IsDeleted=s.IsDeleted, 
						x.Abbreviation=s.Abbreviation
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( Configuration_ID, Name, UpdatedBy, UpdatedTime, CreatedBy, CreatedTime, IsDeleted, Abbreviation)
						VALUES ( s.Configuration_ID, s.Name, s.UpdatedBy, s.UpdatedTime, s.CreatedBy, s.CreatedTime, s.IsDeleted, s.Abbreviation )
				OUTPUT $ACTION,
                	COALESCE(inserted.Configuration_ID, deleted.Configuration_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'ConfigurationInfo Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;


				-- CDS_TroubleshootingInfo
				MERGE sis.TroubleshootingInfo AS x
				USING sis_stage.TroubleshootingInfo AS s
				ON (
				    x.TroubleshootingInfo_ID = s.TroubleshootingInfo_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.TroubleshootingInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.IE_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime
                	EXCEPT
				    SELECT x.TroubleshootingInfo_ID, x.SerialNumberPrefix_ID, x.SerialNumberRange_ID, x.CodeID, x.MIDCodeDetails_ID, x.CIDCodeDetails_ID, x.FMICodeDetails_ID, x.TroubleshootingIllustrationDetails_ID, x.IE_ID, x.InfoType_ID, x.hasGuidedTroubleshooting, x.UpdatedTime
                	)
                    THEN
                    	UPDATE SET x.TroubleshootingInfo_ID = s.TroubleshootingInfo_ID,
                    	    x.SerialNumberPrefix_ID = s.SerialNumberPrefix_ID,
                    	    x.SerialNumberRange_ID = s.SerialNumberRange_ID,
                    	    x.CodeID = s.CodeID,
                    	    x.MIDCodeDetails_ID = s.MIDCodeDetails_ID,
                    	    x.CIDCodeDetails_ID = s.CIDCodeDetails_ID,
                    	    x.FMICodeDetails_ID = s.FMICodeDetails_ID,
                    	    x.TroubleshootingIllustrationDetails_ID = s.TroubleshootingIllustrationDetails_ID,
                    	    x.IE_ID = s.IE_ID,
                    	    x.InfoType_ID = s.InfoType_ID,
                    	    x.hasGuidedTroubleshooting = s.hasGuidedTroubleshooting,
                    	    x.UpdatedTime = s.UpdatedTime
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingInfo_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, CodeID, MIDCodeDetails_ID, CIDCodeDetails_ID, FMICodeDetails_ID, TroubleshootingIllustrationDetails_ID, IE_ID, InfoType_ID, hasGuidedTroubleshooting, UpdatedTime)
						VALUES ( s.TroubleshootingInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.IE_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingInfo_ID, deleted.TroubleshootingInfo_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingInfo Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

			-- CDS_TroubleshootingInfo2 Merge
				MERGE sis.TroubleshootingInfo2 AS x
				USING sis_stage.TroubleshootingInfo2 AS s
				ON (
				    x.TroubleshootingInfo_ID = s.TroubleshootingInfo_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.TroubleshootingInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime
                	EXCEPT
				    SELECT x.TroubleshootingInfo_ID, x.SerialNumberPrefix_ID, x.SerialNumberRange_ID, x.CodeID, x.MIDCodeDetails_ID, x.CIDCodeDetails_ID, x.FMICodeDetails_ID, x.TroubleshootingIllustrationDetails_ID, x.InfoType_ID, x.hasGuidedTroubleshooting, x.UpdatedTime
                	)
                    THEN
                    	UPDATE SET x.TroubleshootingInfo_ID = s.TroubleshootingInfo_ID,
                    	    x.SerialNumberPrefix_ID = s.SerialNumberPrefix_ID,
                    	    x.SerialNumberRange_ID = s.SerialNumberRange_ID,
                    	    x.CodeID = s.CodeID,
                    	    x.MIDCodeDetails_ID = s.MIDCodeDetails_ID,
                    	    x.CIDCodeDetails_ID = s.CIDCodeDetails_ID,
                    	    x.FMICodeDetails_ID = s.FMICodeDetails_ID,
                    	    x.TroubleshootingIllustrationDetails_ID = s.TroubleshootingIllustrationDetails_ID,
                    	    x.InfoType_ID = s.InfoType_ID,
                    	    x.hasGuidedTroubleshooting = s.hasGuidedTroubleshooting,
                    	    x.UpdatedTime = s.UpdatedTime
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingInfo_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, CodeID, MIDCodeDetails_ID, CIDCodeDetails_ID, FMICodeDetails_ID, TroubleshootingIllustrationDetails_ID, InfoType_ID, hasGuidedTroubleshooting, UpdatedTime)
						VALUES ( s.TroubleshootingInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingInfo_ID, deleted.TroubleshootingInfo_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingInfo2 Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

				--TroubleshootingInfoIERelation Merge

				MERGE sis.TroubleshootingInfoIERelation AS x
				USING sis_stage.TroubleshootingInfoIERelation AS s
				ON (
						 x.TroubleshootingInfo_ID = s.TroubleshootingInfo_ID
                AND		 ISNULL(x.IE_ID,999999999) = ISNULL(s.IE_ID,999999999)
				) 
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingInfo_ID, IE_ID)
						VALUES ( s.TroubleshootingInfo_ID, s.IE_ID)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingInfo_ID, deleted.TroubleshootingInfo_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingInfoIERelation Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;



				-- TroubleshootingConfigurationInfo Merge
				
				MERGE sis.TroubleshootingConfigurationInfo AS x
				USING sis_stage.TroubleshootingConfigurationInfo AS s
				ON (
				    x.TroubleshootingConfigurationInfo_ID = s.TroubleshootingConfigurationInfo_ID
				    )
				WHEN MATCHED AND EXISTS (
				    SELECT s.TroubleshootingConfigurationInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.Configuration_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime
                	EXCEPT
				    SELECT x.TroubleshootingConfigurationInfo_ID, x.SerialNumberPrefix_ID, x.SerialNumberRange_ID, x.Configuration_ID, x.CodeID, x.MIDCodeDetails_ID, x.CIDCodeDetails_ID, x.FMICodeDetails_ID, x.TroubleshootingIllustrationDetails_ID, x.InfoType_ID, x.hasGuidedTroubleshooting, x.UpdatedTime
                	)
                    THEN
                    	UPDATE SET x.TroubleshootingConfigurationInfo_ID=s.TroubleshootingConfigurationInfo_ID, 
							x.SerialNumberPrefix_ID=s.SerialNumberPrefix_ID, 
							x.SerialNumberRange_ID=s.SerialNumberRange_ID, 
							x.Configuration_ID=s.Configuration_ID, 
							x.CodeID=s.CodeID, 
							x.MIDCodeDetails_ID=s.MIDCodeDetails_ID, 
							x.CIDCodeDetails_ID=s.CIDCodeDetails_ID, 
							x.FMICodeDetails_ID=s.FMICodeDetails_ID, 
							x.TroubleshootingIllustrationDetails_ID=s.TroubleshootingIllustrationDetails_ID, 
							x.InfoType_ID=s.InfoType_ID, 
							x.hasGuidedTroubleshooting=s.hasGuidedTroubleshooting, 
							x.UpdatedTime=s.UpdatedTime
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingConfigurationInfo_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, Configuration_ID, CodeID, MIDCodeDetails_ID, CIDCodeDetails_ID, FMICodeDetails_ID, TroubleshootingIllustrationDetails_ID, InfoType_ID, hasGuidedTroubleshooting, UpdatedTime)
						VALUES ( s.TroubleshootingConfigurationInfo_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.Configuration_ID, s.CodeID, s.MIDCodeDetails_ID, s.CIDCodeDetails_ID, s.FMICodeDetails_ID, s.TroubleshootingIllustrationDetails_ID, s.InfoType_ID, s.hasGuidedTroubleshooting, s.UpdatedTime)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingConfigurationInfo_ID, deleted.TroubleshootingConfigurationInfo_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingConfigurationInfo Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

				--TroubleshootingConfigurationInfoIERelation Merge

				MERGE sis.TroubleshootingConfigurationInfoIERelation AS x
				USING sis_stage.TroubleshootingConfigurationInfoIERelation AS s
				ON (
						 x.TroubleshootingConfigurationInfo_ID = s.TroubleshootingConfigurationInfo_ID
				AND		 ISNULL(x.IE_ID,999999999) = ISNULL(s.IE_ID,999999999)
				) 
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT ( TroubleshootingConfigurationInfo_ID, IE_ID)
						VALUES ( s.TroubleshootingConfigurationInfo_ID, s.IE_ID)
				OUTPUT $ACTION,
                	COALESCE(inserted.TroubleshootingConfigurationInfo_ID, deleted.TroubleshootingConfigurationInfo_ID) ID
                	INTO @MERGE_RESULTS;

				--OUTPUT $ACTION;
				SELECT @MERGED_ROWS = @@ROWCOUNT;

                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
                    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                    (SELECT MR.ACTIONTYPE, MR.ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH,
                    WITHOUT_ARRAY_WRAPPER),'TroubleshootingConfigurationInfoIERelation Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;


		COMMIT;

		WAITFOR DELAY '00:00:01'
		EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution Completed', @DATAVALUE = NULL;

	END TRY

	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
		    @ERRORLINE INT = ERROR_LINE();

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;
		RAISERROR (@LOGMESSAGE, 17, 1)
		WITH NOWAIT;
	END CATCH
END
GO

