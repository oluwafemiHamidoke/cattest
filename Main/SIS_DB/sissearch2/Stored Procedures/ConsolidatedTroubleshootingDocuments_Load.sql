CREATE  PROCEDURE [sissearch2].[ConsolidatedTroubleshootingDocuments_Load]  AS BEGIN
SET XACT_ABORT,
	NOCOUNT ON;
BEGIN TRY
DECLARE @AFFECTED_ROWS INT = 0,
	@LOGMESSAGE VARCHAR(MAX),
	@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
	@ProcessID UNIQUEIDENTIFIER = NEWID(),
	@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE(),
	@StartTime DATETIME,
	@SOURCE_TABLE_ROW_COUNT INT = 0,
	@TimeMarker datetime = getdate(),
	@LAPSETIME int = 0;


EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = 'Execution started',
	@DATAVALUE = NULL;

BEGIN TRANSACTION;
SET @AFFECTED_ROWS = (select count(*) from [sissearch2].[CONSOLIDATEDTROUBLESHOOTINGDOCUMENTS]);
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Rows Before Merge',
	@DATAVALUE = @AFFECTED_ROWS;
;

declare @PROFILE_MUST_INCLUDE int = 1,
	@PROFILE_MUST_EXCLUDE int = 0;
declare @PROFILE_INCLUDE_ALL int = 0,
	@PROFILE_EXCLUDE_ALL int = -1;

-- read permission values
declare @prodFamilyID int, @snpID int, @infoTypeID int;

select @prodFamilyID = PermissionType_ID
from admin.Permission
where PermissionType_Description='productFamily'
select @snpID = PermissionType_ID
from admin.Permission
where PermissionType_Description='serialNumberPrefix'
select @infoTypeID = PermissionType_ID
from admin.Permission
where PermissionType_Description='informationType'

--
-- Create a temp table with detailed PermissionType(family,snp,infotype) for
-- each Troubleshooting_ID
--

DROP TABLE IF EXISTS #TroubleshootingInfoType
SELECT CodeID, @infoTypeID  PermissionType_ID, ti.InfoType_ID as Permission_Detail_ID
INTO #TroubleshootingInfoType
FROM [sis].[TroubleshootingInfo] ti

DROP TABLE IF EXISTS #AccessProdInfoType
select m.CodeID, e.Profile_ID
into #AccessProdInfoType
from #TroubleshootingInfoType m
	inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
		(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
		AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
GROUP BY m.CodeID, e.Profile_ID

DROP TABLE IF EXISTS #TroubleshootingProfile
select z.CodeID, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
into #TroubleshootingProfile
from (
	select ps.CodeID, ps.Profile_ID
	from #AccessProdInfoType ps
	group by ps.CodeID, ps.Profile_ID
) z
GROUP BY z.CodeID



DROP TABLE IF EXISTS #TroubleshootingInfo
select
	snp.Serial_Number_Prefix
, snr.Start_Serial_Number
, snr.End_Serial_Number
, ti.CodeID
, mid.MIDCode
, cid.CIDCode
, cid.CIDType
, fmi.FMICode
, fmi.FMIType
, ti.InfoType_ID
, ti.hasGuidedTroubleshooting
INTO #TroubleshootingInfo
FROM [sis].[TroubleshootingInfo] ti
	JOIN sis.MIDCodeDetails mid ON ti.MIDCodeDetails_ID = mid.MIDCodeDetails_ID
	JOIN sis.CIDCodeDetails cid ON ti.CIDCodeDetails_ID = cid.CIDCodeDetails_ID
	JOIN sis.FMICodeDetails fmi ON ti.FMICodeDetails_ID = fmi.FMICodeDetails_ID
	JOIN sis.SerialNumberPrefix snp ON ti.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
	JOIN sis.SerialNumberRange snr ON ti.SerialNumberRange_ID = snr.SerialNumberRange_ID
group by 
snp.Serial_Number_Prefix
,snr.Start_Serial_Number
,snr.End_Serial_Number
, ti.CodeID
, mid.MIDCode
, cid.CIDCode
, cid.CIDType
, fmi.FMICode
, fmi.FMIType
, ti.InfoType_ID
, ti.hasGuidedTroubleshooting

SET @SOURCE_TABLE_ROW_COUNT = (select count(*) from #TroubleshootingInfo tsi join #TroubleshootingProfile tsp on tsi.CodeID = tsp.CodeID);
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Rows in source dataset',
	@DATAVALUE = @SOURCE_TABLE_ROW_COUNT ;

MERGE  [sissearch2].[CONSOLIDATEDTROUBLESHOOTINGDOCUMENTS] AS TARGET USING (

select 
ID,
Codes,
SerialNumbers,
hasGuidedTroubleshooting,
'["'+string_agg(InfoType_ID, ',') WITHIN GROUP (ORDER BY InfoType_ID ASC)+'"]' as InformationType,
Profile
from
(
select
    'TroubleshootingCodeID_'+CAST(tsi.CodeID as varchar) as ID,
	'["' + CAST(MIDCode AS VARCHAR) + '-' + CIDCode + '-' + CAST(FMICode AS VARCHAR) + '", "MID ' + CAST(MIDCode AS VARCHAR) +' '+CIDType+' ' + CIDCode +' '+FMIType+' '+ CAST(FMICode AS VARCHAR) + CASE WHEN CIDType='EVENT' AND FMIType='SEVERITY' THEN  '", "' +CAST(MIDCode AS VARCHAR) + '-' + CIDCode + ' (' + CAST(FMICode AS VARCHAR)+ ')"]' ELSE '"]' END Codes,
	'[{"serialNumberPrefixes":["' + Serial_Number_Prefix + '"],"beginRange":' + CAST(Start_Serial_Number AS VARCHAR) + ',"endRange":' + CAST(End_Serial_Number AS VARCHAR) + '}]' SerialNumbers,
	[hasGuidedTroubleshooting],
	InfoType_ID,
	Profile 
from #TroubleshootingInfo tsi join #TroubleshootingProfile tsp on tsi.CodeID = tsp.CodeID
) a
GROUP BY ID,
Codes,
SerialNumbers,
hasGuidedTroubleshooting,
Profile
)
 AS SOURCE ON (
	TARGET.[ID] = SOURCE.[ID]

)
WHEN MATCHED
	AND 
	   TARGET.[Codes] <> SOURCE.[Codes]
	OR TARGET.[SerialNumbers] <> SOURCE.[SerialNumbers]
	OR TARGET.[hasGuidedTroubleshooting] <> SOURCE.[hasGuidedTroubleshooting]
	OR TARGET.[InformationType] <> SOURCE.[InformationType]
	OR TARGET.[Profile] <> SOURCE.[Profile]
THEN 
UPDATE
SET 
	 TARGET.[Codes] = SOURCE.[Codes],
	 TARGET.[SerialNumbers] = SOURCE.[SerialNumbers],
	 TARGET.[hasGuidedTroubleshooting] = SOURCE.[hasGuidedTroubleshooting],
	 TARGET.[InformationType] = SOURCE.[InformationType],
	 TARGET.[Profile] = SOURCE.[Profile]

WHEN NOT MATCHED BY TARGET THEN
INSERT 
(
		[ID],
		[Codes],
		[SerialNumbers],
		[hasGuidedTroubleshooting],
		[InformationType],
		[Profile]
	)
	VALUES
	(
		SOURCE.[ID],
		SOURCE.[Codes],
		SOURCE.[SerialNumbers],
		SOURCE.[hasGuidedTroubleshooting],
		SOURCE.[InformationType],
		SOURCE.[Profile]
	)
WHEN NOT MATCHED BY SOURCE AND (@SOURCE_TABLE_ROW_COUNT!=0)  THEN DELETE;



set @AFFECTED_ROWS = @@ROWCOUNT;
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Affected by merge',
	@DATAVALUE = @AFFECTED_ROWS;

SET @AFFECTED_ROWS = (select count(*) from [sissearch2].[CONSOLIDATEDTROUBLESHOOTINGDOCUMENTS]);
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Rows After Merge',
	@DATAVALUE = @AFFECTED_ROWS;
;

IF @SOURCE_TABLE_ROW_COUNT=0
       EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Error',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Delete target was NOT executed becuase source dataset has zero rows',
	@DATAVALUE = NULL;;



COMMIT;

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());

EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LAPSETIME = @LAPSETIME,
	@LOGMESSAGE = 'Execution Completed',
	@DATAVALUE = NULL;
END TRY 

BEGIN CATCH
	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
	DECLARE @ERRORLINE INT = ERROR_LINE()
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	EXEC sissearch2.WriteLog 
	@LOGTYPE = 'Error',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = @ERRORMESSAGE,
	@DATAVALUE = NULL;
END CATCH
END
GO
