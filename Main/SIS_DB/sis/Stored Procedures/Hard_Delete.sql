-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Hard delete all records from sis schema where isDeleted = 1 (soft deleted)
-- Update Date: 20230209
-- Reason: LINE 348: The DELETE statement conflicted with the REFERENCE constraint "FK_IEPart_Effectivity_Media". The conflict occurred in database "sis", table "sis.IEPart_Effectivity", column 'Media_ID'.LINE 348: The DELETE statement conflicted with the REFERENCE constraint "FK_IEPart_Effectivity_Media". The conflict occurred in database "sis", table "sis.IEPart_Effectivity", column 'Media_ID'.
-- Description: Updated IEPart_Effectivity Delete with addtional JOIN condition on Media_ID since the corresponding Merge procedure was updated [sis].[IEPart_Effectivity_Merge]
-- Anytime changed to Merge procs are done, check the corresponding Delete statement in [sis].[Hard_Delete] if the JOIN conditions needs to be updated as well. 
-- =============================================
CREATE PROCEDURE  [sis].[Hard_Delete]

AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
Declare @ProcessID uniqueidentifier = NewID()

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

---- New tables
EXEC sis.SMCS_IEPart_Relation_Delete
Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SMCS_IEPart_Relation_Delete completed', NULL)

EXEC sis.SerialNumber_Media_Relation_Delete
Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumber_Media_Relation_Delete completed', NULL)

EXEC sis.CaptivePrime_Serial_Delete
Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CaptivePrime_Serial_Delete completed', NULL)

EXEC sis.SerialNumber_Delete
Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumber_Delete completed', NULL)

--Hard Delete
delete x
  FROM sis.ProductStructure_Effectivity x
	   left outer join sis_stage.ProductStructure_Effectivity s ON
																   s.ProductStructure_ID = x.ProductStructure_ID
																   AND s.Media_ID = x.Media_ID
																   AND s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID
																   AND s.SerialNumberRange_ID = x.SerialNumberRange_ID
  Where s.ProductStructure_ID is null
  and s.Media_ID is null
  and s.SerialNumberPrefix_ID is null
  and s.SerialNumberRange_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductStructure_Effectivity Hard Delete', @@RowCount)

--Hard Delete
DELETE tgt
FROM [sis].[Media_ProductFamily_Effectivity] tgt
Left Outer join [sis_stage].[Media_ProductFamily_Effectivity] src on src.ProductFamily_ID = tgt.ProductFamily_ID and src.Media_ID = tgt.Media_ID
Where src.Media_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Media_ProductFamily_Effectivity Hard Delete', @@RowCount)

--Hard Delete
/*
delete x
FROM [sis].[SerializedComponent_Effectivity] x
left outer join [sis_stage].[SerializedComponent_Effectivity] s on s.AsShippedPart_Effectivity_ID = x.AsShippedPart_Effectivity_ID and s.SerialNumber = x.SerialNumber
Where s.SerializedComponent_Effectivity_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerializedComponent_Effectivity Hard Delete', @@RowCount)

--Hard Delete
Delete x
From [sis].[AsShippedPart_Effectivity] x
left outer join [sis_stage].[AsShippedPart_Effectivity] s on s.AsShippedPart_ID = x.AsShippedPart_ID and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID
where s.AsShippedPart_Effectivity_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.AsShippedPart_Effectivity Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Part_AsShippedPart_Relation] x
left outer join [sis_stage].[Part_AsShippedPart_Relation] s on s.Part_ID = x.Part_ID and s.AsShippedPart_ID = x.AsShippedPart_ID
Where s.Part_AsShippedPart_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_AsShippedPart_Relation Hard Delete', @@RowCount)


--Hard Delete
delete x
FROM [sis].[Part_AsShippedEngine_Relation] x
left outer join [sis_stage].[Part_AsShippedEngine_Relation] s on s.AsShippedEngine_ID = x.AsShippedEngine_ID and s.Part_ID = x.Part_ID and s.Sequence_Number = x.Sequence_Number
Where s.Part_AsShippedEngine_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_AsShippedEngine_Relation Hard Delete', @@RowCount)

--Hard Delete
Delete x
From [sis].[AsShippedPart] x
left outer join [sis_stage].[AsShippedPart] s on s.Part_ID = x.Part_ID
where s.AsShippedPart_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.AsShippedPart Hard Delete', @@RowCount)

--Hard Delete
Delete x
From [sis].[AsShippedEngine] x
left outer join [sis_stage].[AsShippedEngine] s on s.Part_ID = x.Part_ID and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID and s.Sequence_Number = x.Sequence_Number
where s.AsShippedEngine_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.AsShippedEngine Hard Delete', @@RowCount)
*/
--Hard Delete
delete x
FROM [sis].[SupersessionChain_Part_Relation] x
left outer join [sis_stage].[SupersessionChain_Part_Relation] s on s.SupersessionChain_ID = x.SupersessionChain_ID and s.Part_ID = x.Part_ID
Where s.SupersessionChain_ID is null and s.Part_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SupersessionChain_Part_Relation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[SupersessionChain] x
left outer join [sis_stage].[SupersessionChain] s on s.SupersessionChain = x.SupersessionChain
Where s.SupersessionChain_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SupersessionChain Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Supersession_Part_Relation] x
left outer join [sis_stage].[Supersession_Part_Relation] s on s.Part_ID = x.Part_ID and s.Supersession_Part_ID = x.Supersession_Part_ID
Where s.Supsersession_Part_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Supersession_Part_Relation Hard Delete', @@RowCount)

--Hard Delete
Delete x
From [sis].[CaptivePrime] x
left outer join [sis_stage].[CaptivePrime] s on s.Prime_SerialNumberPrefix_ID = x.Prime_SerialNumberPrefix_ID and s.Captive_SerialNumberPrefix_ID = x.Captive_SerialNumberPrefix_ID and s.Captive_SerialNumberRange_ID = x.Captive_SerialNumberRange_ID and s.Media_ID = x.Media_ID
where s.CaptivePrime_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CaptivePrime Hard Delete', @@RowCount)

--Hard Delete
Delete x
From [sis].[IEPart_Illustration_Relation] x
left outer join [sis_stage].[IEPart_Illustration_Relation] s on s.Illustration_ID = x.Illustration_ID and s.IEPart_ID = x.IEPart_ID --and s.Graphic_Number = x.Graphic_Number
where s.Illustration_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IEPart_Illustration_Relation Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.IE_Illustration_Relation
FROM sis.IE_Illustration_Relation x
	 INNER JOIN sis_stage.IE_Illustration_Relation_Diff s ON s.Illustration_ID = x.Illustration_ID AND
													 s.IE_ID = x.IE_ID AND s.Graphic_Number = x.Graphic_Number
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_Illustration_Relation Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis].[Illustration_File] x
left outer join [sis_stage].[Illustration_File] s on s.Illustration_ID = x.Illustration_ID and s.File_Location = x.File_Location
where s.Illustration_File_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Illustration_File Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis].[Illustration] x
left outer join [sis_stage].[Illustration] s on s.Graphic_Control_Number = x.Graphic_Control_Number
where s.Illustration_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Illustration Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductStructure_IEPart_Relation] x
left outer join [sis_stage].[ProductStructure_IEPart_Relation] s on s.ProductStructure_ID = x.ProductStructure_ID and s.IEPart_ID = x.IEPart_ID and s.Media_ID = x.Media_ID and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID
Where s.ProductStructure_ID is null and s.IEPart_ID is null and s.Media_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductStructure_IEPart_Relation Hard Delete', @@RowCount)

--Hard Delete
DELETE [sis].[ProductStructure_IE_Relation]
FROM [sis].[ProductStructure_IE_Relation] x
Inner join [sis_stage].[ProductStructure_IE_Relation_Diff] s on s.ProductStructure_ID = x.ProductStructure_ID and s.IE_ID = x.IE_ID and s.Media_ID = x.Media_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductStructure_IE_Relation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductStructure_Translation] x
left outer join [sis_stage].[ProductStructure_Translation] s on s.ProductStructure_ID = x.ProductStructure_ID and s.Language_ID = x.Language_ID
Where s.ProductStructure_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductStructure_Translation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductStructure] x
left outer join [sis_stage].[ProductStructure] s on s.ProductStructure_ID = x.ProductStructure_ID
Where s.ProductStructure_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductStructure Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Part_IEPart_Relation_Translation] x
left outer join [sis_stage].[Part_IEPart_Relation_Translation] s on s.Part_IEPart_Relation_ID = x.Part_IEPart_Relation_ID and s.Language_ID = x.Language_ID
Where s.Part_IEPart_Relation_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_IEPart_Relation_Translation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Part_IEPart_Relation] x
left outer join [sis_stage].[Part_IEPart_Relation] s on s.Part_ID = x.Part_ID and s.IEPart_ID = x.IEPart_ID and s.Sequence_Number = x.Sequence_Number
Where s.Part_IEPart_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_IEPart_Relation Hard Delete', @@RowCount)

-- IEPart_Effectivity Hard Delete
DELETE x
FROM [sis].[IEPart_Effectivity] x
LEFT OUTER JOIN [sis_stage].[IEPart_Effectivity] s on  s.IEPart_ID = x.IEPart_ID 
	AND s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID 
	AND s.SerialNumberRange_ID = x.SerialNumberRange_ID 
	AND s.SerialNumberPrefix_Type = x.SerialNumberPrefix_Type
	AND s.Media_ID = x.Media_ID 
	where s.IEPart_ID IS NULL
	OR s.SerialNumberRange_ID IS NULL
	OR s.SerialNumberPrefix_Type IS NULL
	OR s.Media_ID IS NULL

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IEPart_Effectivity Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis].[MediaSequence_Effectivity] x
left outer join [sis_stage].[MediaSequence_Effectivity] s on s.[MediaSequence_ID] = x.[MediaSequence_ID] and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID
where s.MediaSequence_ID is null and s.SerialNumberPrefix_ID is null and s.SerialNumberRange_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MediaSequence_Effectivity Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[MediaSequence_Translation] x
left outer join [sis_stage].[MediaSequence_Translation] s on s.[MediaSequence_ID] = x.[MediaSequence_ID] and s.Language_ID = x.Language_ID
Where s.MediaSequence_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MediaSequence_Translation Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis_shadow].[MediaSequence] x
left outer join [sis_stage].[MediaSequence] s on s.[MediaSection_ID] = x.[MediaSection_ID] and s.IEPart_ID = x.IEPart_ID and s.Sequence_Number = x.Sequence_Number and s.IE_ID = x.IE_ID
where s.MediaSequence_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MediaSequence Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis].[MediaSection_Translation] x
left outer join [sis_stage].[MediaSection_Translation] s on s.[MediaSection_ID] = x.[MediaSection_ID] and s.Language_ID = x.Language_ID
where s.MediaSection_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MediaSection_Translation Hard Delete', @@RowCount)

--Hard Delete
Delete x
FROM [sis].[MediaSection] x
left outer join [sis_stage].[MediaSection] s on s.Media_ID = x.Media_ID and s.Section_Number = x.Section_Number
where s.MediaSection_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MediaSection Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Media_Effectivity] x
left outer join [sis_stage].[Media_Effectivity] s on s.Media_ID = x.Media_ID and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID
Where s.Media_ID is null and s.SerialNumberPrefix_ID is null and s.SerialNumberRange_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Media_Effectivity Hard Delete', @@RowCount)

--Hard Delete
Delete tgt
FROM [sis].[Media_InfoType_Relation] tgt
left outer join [sis_stage].[Media_InfoType_Relation] src on src.Media_ID = tgt.Media_ID and src.InfoType_ID = tgt.InfoType_ID
where src.Media_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Media_InfoType_Relation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Media_Translation] x
left outer join [sis_stage].[Media_Translation] s on s.Media_ID = x.Media_ID and s.Language_ID = x.Language_ID
Where s.Media_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Media_Translation Hard Delete', @@RowCount)

--Hard Delete
DELETE tgt
FROM [sis].[IE_Effectivity] tgt
left outer join [sis_stage].[IE_Effectivity] src on src.IE_ID = tgt.IE_ID
			and src.SerialNumberPrefix_ID = tgt.SerialNumberPrefix_ID
			and src.SerialNumberRange_ID = tgt.SerialNumberRange_ID
			and src.Media_ID = tgt.Media_ID
where src.IE_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_Effectivity Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Kit_Media_Relation] x
left outer join [sis_stage].[Media] s on s.Media_ID = x.Media_ID
Where s.Media_ID is NULL

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit_Media_Relation Hard Delete', @@RowCount)

delete x 
FROM [sis].[Kit_Media_Relation] x
inner join [sis].[Kit] k on k.Kit_ID=x.Kit_ID
left outer join [KIM].[SIS_KitNumbers] s on s.KITNUMBER = k.Number
where s.KITNUMBER is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit_Media_Relation KIM Hard Delete', @@RowCount)


DELETE kits_target
FROM [sis].[Kit] kits_target
LEFT JOIN [KIM].[SIS_KitNumbers] kit_source ON kit_source.KITNUMBER = kits_target.Number
WHERE kit_source.KITNUMBER is NULL;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit Hard Delete', @@RowCount)


--Hard Delete
DELETE [sis].[SMCS_IE_Relation]
FROM [sis].[SMCS_IE_Relation] x
Inner join [sis_stage].[SMCS_IE_Relation_Diff] s on s.SMCS_ID = x.SMCS_ID
AND 												   s.IE_ID = x.IE_ID AND s.Media_ID=x.Media_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SMCS_IE_Relation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Media] x
left outer join [sis_stage].[Media] s on s.Media_Number = x.Media_Number
Where s.Media_ID is NULL

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Media Hard Delete', @@RowCount)

--Hard Delete
DELETE tgt
FROM [sis].[IEPart_Effective_Date] tgt
left join [sis_stage].[IEPart_Effective_Date] src on src.IEPart_ID = tgt.IEPart_ID
    and src.SerialNumberPrefix_ID = tgt.SerialNumberPrefix_ID
    and src.SerialNumberRange_ID = tgt.SerialNumberRange_ID
    and src.Media_ID = tgt.Media_ID
    and src.DayEffective = tgt.DayEffective
Where src.IEPart_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IEPart_Effective_Date Hard Delete', @@RowCount)


--Hard Delete
Delete x
FROM [sis].[IEPart] x
left outer join [sis_stage].[IEPart] s on s.Base_English_Control_Number = x.Base_English_Control_Number
where s.IEPart_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IEPart Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Related_Part_Relation] x
left outer join [sis_stage].[Related_Part_Relation] s on s.Related_Part_ID = x.Related_Part_ID and s.Part_ID = x.Part_ID and s.Type_Indicator = x.Type_Indicator
Where s.Related_Part_Relation_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Related_Part_Relation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Part_Translation] x
left outer join [sis_stage].[Part_Translation] s on s.Part_ID = x.Part_ID and s.Language_ID = x.Language_ID
Where s.Part_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_Translation Hard Delete', @@RowCount)

-- 20200618 Davide: Hard Delete PartHistory before Part
DELETE FROM sis.PartHistory
WHERE Part_ID IN(SELECT tgt.Part_ID
				   FROM sis.Part AS tgt
						LEFT OUTER JOIN sis_stage.Part AS src ON src.Part_Number = tgt.Part_Number AND src.Org_Code = tgt.Org_Code
				   WHERE src.Part_Number is null);

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.PartHistory Hard Delete', @@RowCount)

--Hard Delete
Delete sis.Kit_ParentPart_Relation
from sis.Kit_ParentPart_Relation y
Inner join [sis].[Part] tgt on  tgt.Part_ID = y.ParentPart_ID
Left Outer join [sis_stage].[Part] src on src.Part_Number = tgt.Part_Number AND src.Org_Code = tgt.Org_Code
Where src.Part_Number is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit_ParentPart_Relation Hard Delete', @@RowCount)


--Hard Delete Part_ImageIdentifier before Part delete
delete x
FROM [sis].[Part_ImageIdentifier] x
Inner join [sis].[Part] tgt on  tgt.Part_ID = x.Part_ID
left outer join [sis_stage].[Part] s on s.Part_Number = tgt.Part_Number AND s.Org_Code = tgt.Org_Code
Where s.Part_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part_ImageIdentifier Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Part] x
left outer join [sis_stage].[Part] s on s.Part_Number = x.Part_Number AND s.Org_Code = x.Org_Code
Where s.Part_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Part Hard Delete', @@RowCount)

--Hard Delete
delete y2
from sis.Kit_Effectivity y2
inner join [sis].[Kit_Effectivity] y on y2.Parent_ID = y.Kit_Effectivity_ID
inner join [sis].[SerialNumberRange] x on x.SerialNumberRange_ID = y.SerialNumberRange_ID
left outer join [sis_stage].[SerialNumberRange] s on s.Start_Serial_Number = x.Start_Serial_Number and s.End_Serial_Number = x.End_Serial_Number
Where s.Start_Serial_Number is null and s.End_Serial_Number is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit_Effectivity using SNR Hard Delete2', @@RowCount)

delete y
from sis.Kit_Effectivity y
inner join [sis].[SerialNumberRange] x on x.SerialNumberRange_ID = y.SerialNumberRange_ID
left outer join [sis_stage].[SerialNumberRange] s on s.Start_Serial_Number = x.Start_Serial_Number and s.End_Serial_Number = x.End_Serial_Number
Where s.Start_Serial_Number is null and s.End_Serial_Number is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Kit_Effectivity using SNR Hard Delete', @@RowCount)
--Hard Delete:  ServiceSoftware_Effectivity_Suffix

DELETE x
FROM [sis].[ServiceSoftware_Effectivity_Suffix] x
WHERE ServiceSoftware_Effectivity_ID IN (
    SELECT x.ServiceSoftware_Effectivity_ID
    FROM [sis].[ServiceSoftware_Effectivity] x
    LEFT OUTER JOIN [sis_stage].[ServiceSoftware_Effectivity] s ON s.ServiceSoftware_Effectivity_ID = x.ServiceSoftware_Effectivity_ID
    LEFT OUTER JOIN [sis_stage].[SerialNumberPrefix] snp ON snp.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID 
    WHERE s.ServiceSoftware_Effectivity_ID IS NULL
    OR snp.SerialNumberPrefix_ID IS NULL
);

--Hard Delete:  ServiceSoftware_Effectivity
delete x
FROM [sis].[ServiceSoftware_Effectivity] x
left outer join [sis_stage].[ServiceSoftware_Effectivity] s on s.ServiceSoftware_Effectivity_ID = x.ServiceSoftware_Effectivity_ID
left outer join [sis_stage].[SerialNumberPrefix] snp on snp.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID 
Where s.ServiceSoftware_Effectivity_ID is null
 or snp.SerialNumberPrefix_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ServiceSoftware_Effectivity Hard Delete', @@RowCount);

--Hard Delete
delete x
FROM [sis].[SerialNumberRange] x
left outer join [sis_stage].[SerialNumberRange] s on s.Start_Serial_Number = x.Start_Serial_Number and s.End_Serial_Number = x.End_Serial_Number
Where s.SerialNumberRange_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumberRange Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductFamily_Translation] x
left outer join [sis_stage].[ProductFamily_Translation] s on s.ProductFamily_ID = x.ProductFamily_ID and s.Language_ID = x.Language_ID
Where s.ProductFamily_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductFamily_Translation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductSubfamily_Translation] x
left outer join [sis_stage].[ProductSubfamily_Translation] s on s.ProductSubfamily_ID = x.ProductSubfamily_ID and s.Language_ID = x.Language_ID
Where s.ProductSubfamily_ID is null and s.Language_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductSubfamily_Translation Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[Product_Relation] x
left outer join [sis_stage].[Product_Relation] s on s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SalesModel_ID = x.SalesModel_ID and s.ProductSubfamily_ID = x.ProductSubfamily_ID and s.ProductFamily_ID = x.ProductFamily_ID
Where s.SerialNumberPrefix_ID is null and s.SalesModel_ID is null and s.ProductSubfamily_ID is null and s.ProductFamily_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Product_Relation Hard Delete', @@RowCount)

--Hard Delete
delete tgt
FROM [sis].[IE_ProductFamily_Effectivity] tgt
left outer join [sis_stage].[IE_ProductFamily_Effectivity] src  on src.ProductFamily_ID = tgt.ProductFamily_ID and src.IE_ID = tgt.IE_ID
Where src.ProductFamily_ID is null and src.IE_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_ProductFamily_Effectivity Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductFamily] x
left outer join [sis_stage].[ProductFamily] s on s.Family_Code = x.Family_Code
Where s.ProductFamily_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductFamily Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[ProductSubfamily] x
left outer join [sis_stage].[ProductSubfamily] s on s.Subfamily_Code = x.Subfamily_Code
Where s.ProductSubfamily_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ProductSubfamily Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[SalesModel] x
left outer join [sis_stage].[SalesModel] s on s.Sales_Model = x.Sales_Model
Where s.SalesModel_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SalesModel Hard Delete', @@RowCount)

--Hard Delete
delete y2
from sis.Kit_Effectivity y2
inner join [sis].[Kit_Effectivity] y on y2.Parent_ID = y.Kit_Effectivity_ID
inner join [sis].[SerialNumberPrefix] x on x.SerialNumberPrefix_ID = y.SerialNumberPrefix_ID
left outer join [sis_stage].[SerialNumberPrefix] s on s.Serial_Number_Prefix = x.Serial_Number_Prefix
Where s.Serial_Number_Prefix is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Kit_Effectivity using SNP Hard Delete2', @@RowCount)

delete y
from sis.Kit_Effectivity y
inner join [sis].[SerialNumberPrefix] x on x.SerialNumberPrefix_ID = y.SerialNumberPrefix_ID
Inner join [sis_stage].[SerialNumberPrefix] s on s.Serial_Number_Prefix = x.Serial_Number_Prefix
Where s.Serial_Number_Prefix is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Kit_Effectivity using SNP Hard Delete', @@RowCount)

--Hard Delete 
delete x
FROM sis.ServiceLetterCompletion  x
left outer join [sis_stage].[SerialNumberPrefix] s on s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID
Where s.SerialNumberPrefix_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ServiceLetterCompletion Hard Delete', @@RowCount)

--Hard Delete
delete x
FROM [sis].[SerialNumberPrefix] x
left outer join [sis_stage].[SerialNumberPrefix] s on s.Serial_Number_Prefix = x.Serial_Number_Prefix
Where s.SerialNumberPrefix_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumberPrefix Hard Delete', @@RowCount)

--Hard Delete
delete tgt
FROM [sis].[Language] tgt
left outer join [sis_stage].[Language] src on src.Language_Tag = tgt.Language_Tag
Where src.Language_Tag is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Language Hard Delete', @@RowCount)

--Hard Delete
delete tgt
FROM [sis].[Language_Details] tgt
left outer join [sis_stage].[Language_Details] src on src.Language_Tag = tgt.Language_Tag
Where src.Language_Tag is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Language_Details Hard Delete', @@RowCount)

--Hard Delete
DELETE [sis].[SMCS_Translation]
FROM [sis].[SMCS_Translation] x
Inner join [sis_stage].[SMCS_Translation_Diff] s on s.SMCS_ID = x.SMCS_ID AND s.Language_ID = x.Language_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SMCS_Translation Hard Delete', @@RowCount)


--Hard Delete
DELETE [sis].[SMCS]
FROM [sis].[SMCS] x
Inner join [sis_stage].[SMCS_Diff] s on s.SMCSCOMPCODE = x.SMCSCOMPCODE
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SMCS Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.IE_Dealer_Relation
FROM sis.IE_Dealer_Relation x
	 INNER JOIN sis_stage.IE_Dealer_Relation_Diff s ON s.Dealer_ID = x.Dealer_ID AND
													 s.IE_ID = x.IE_ID
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_Dealer_Relation Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.IE_MarketingOrg_Relation
FROM sis.IE_MarketingOrg_Relation x
	 INNER JOIN sis_stage.IE_MarketingOrg_Relation_Diff s ON s.IE_ID = x.IE_ID AND s.MarketingOrg_ID = x.MarketingOrg_ID
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_MarketingOrg_Relation Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.IE_Translation
FROM sis.IE_Translation x
	 INNER JOIN sis_stage.IE_Translation_Diff s ON s.Language_ID = x.Language_ID AND
													 s.IE_ID = x.IE_ID
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_Translation Hard Delete', @@RowCount)

--Hard Delete
DELETE [sis].[IE_InfoType_Relation]
FROM [sis].[IE_InfoType_Relation] x
Inner join [sis_stage].[IE_InfoType_Relation_Diff] s on s.InfoType_ID = x.InfoType_ID
AND 												   s.IE_ID = x.IE_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_InfoType_Relation Hard Delete', @@RowCount)

--Hard Delete
DELETE [sis].[IE_StaticIllustration_Relation]
FROM [sis].[IE_StaticIllustration_Relation] x
Inner join [sis_stage].[IE_Diff] s on s.IE_ID = x.IE_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE_StaticIllustration_Relation Delete based on [sis_stage].[IE_Diff]', @@RowCount)

--Hard Delete: TroubleshootingInfo
delete x
FROM [sis].[TroubleshootingInfo] x
left outer join [sis_stage].[TroubleshootingInfo] s on s.TroubleshootingInfo_ID = x.TroubleshootingInfo_ID
Where s.TroubleshootingInfo_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingInfo Hard Delete', @@RowCount);

--Hard Delete: TroubleshootingInfoIERelation
delete x
FROM [sis].[TroubleshootingInfoIERelation] x
left outer join [sis_stage].[TroubleshootingInfoIERelation] s 
on 
(
s.TroubleshootingInfo_ID = x.TroubleshootingInfo_ID
AND 
ISNULL(x.IE_ID,999999999) = ISNULL(s.IE_ID,999999999)
)
Where s.TroubleshootingInfo_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingInfoIERelation Hard Delete', @@RowCount);

--Hard Delete: TroubleshootingInfo2
delete x
FROM [sis].[TroubleshootingInfo2] x
left outer join [sis_stage].[TroubleshootingInfo2] s 
on s.TroubleshootingInfo_ID = x.TroubleshootingInfo_ID
Where s.TroubleshootingInfo_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingInfo2 Hard Delete', @@RowCount);

--Hard Delete: TroubleshootingConfigurationInfoIERelation
delete x
FROM [sis].[TroubleshootingConfigurationInfoIERelation] x
left outer join [sis_stage].[TroubleshootingConfigurationInfoIERelation] s 
on 
(
s.TroubleshootingConfigurationInfo_ID = x.TroubleshootingConfigurationInfo_ID
AND 
ISNULL(x.IE_ID,999999999) = ISNULL(s.IE_ID,999999999)
)
Where s.TroubleshootingConfigurationInfo_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingConfigurationInfoIERelation Hard Delete', @@RowCount);

--Hard Delete: TroubleshootingConfigurationInfo
delete x
FROM [sis].[TroubleshootingConfigurationInfo] x
left outer join [sis_stage].[TroubleshootingConfigurationInfo] s 
on s.TroubleshootingConfigurationInfo_ID = x.TroubleshootingConfigurationInfo_ID
Where s.TroubleshootingConfigurationInfo_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingConfigurationInfo Hard Delete', @@RowCount);

--Hard Delete: ConfigurationInfo
delete x
FROM [sis].[ConfigurationInfo] x
left outer join [sis_stage].[ConfigurationInfo] s on s.Configuration_ID = x.Configuration_ID
Where s.Configuration_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ConfigurationInfo Hard Delete', @@RowCount);


--Hard Delete
DELETE [sis].[IE]
FROM [sis].[IE] x
Inner join [sis_stage].[IE_Diff] s on s.IESystemControlNumber = x.IESystemControlNumber
--AND 												   s.InfoType_ID = x.InfoType_ID
Where s.Operation = 'Delete'

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IE Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.Dealer
FROM sis.Dealer x
	 INNER JOIN sis_stage.Dealer_Diff s ON s.Dealer_Code = x.Dealer_Code
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.Dealer Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.MarketingOrg
FROM sis.MarketingOrg x
	 INNER JOIN sis_stage.MarketingOrg_Diff s ON s.MarketingOrg_Code = x.MarketingOrg_Code
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MarketingOrg Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.InfoType_Translation
FROM sis.InfoType_Translation x
	 INNER JOIN sis_stage.InfoType_Translation_Diff s ON s.InfoType_ID = x.InfoType_ID AND s.Language_ID = x.Language_ID
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.InfoType_Translation Hard Delete', @@RowCount)

--Hard Delete
DELETE sis.InfoType
FROM sis.InfoType x
	 INNER JOIN sis_stage.InfoType_Diff s ON s.InfoType_ID = x.InfoType_ID
WHERE s.Operation = 'Delete';

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.InfoType Hard Delete', @@RowCount)

--Hard Delete: ServiceFile_DisplayTerms_Translation
delete x
FROM [sis].[ServiceFile_DisplayTerms_Translation] x
left outer join [sis_stage].[ServiceFile_DisplayTerms_Translation] s
on s.ServiceFile_DisplayTerms_ID = x.ServiceFile_DisplayTerms_ID AND s.Language_ID = x.Language_ID
Where s.ServiceFile_DisplayTerms_ID is null and s.Language_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ServiceFile_DisplayTerms_Translation Hard Delete', @@RowCount);

--Hard Delete: ServiceFile_DisplayTerms
delete x
FROM [sis].[ServiceFile_DisplayTerms] x
left outer join [sis_stage].[ServiceFile_DisplayTerms] s
on s.ServiceFile_ID = x.ServiceFile_ID and s.Type = x.Type
Where s.ServiceFile_DisplayTerms_ID is null

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ServiceFile_DisplayTerms Hard Delete', @@RowCount);

--Hard Delete: ServiceFile
delete x
FROM [sis].[ServiceFile] x
left outer join [sis_stage].[ServiceFile] s on s.ServiceFile_ID = x.ServiceFile_ID
Where s.ServiceFile_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.ServiceFile Hard Delete', @@RowCount);

--Hard Delete: MIDCodeDetails
delete x
FROM [sis].[MIDCodeDetails] x
left outer join [sis_stage].[MIDCodeDetails] s on s.MIDCodeDetails_ID = x.MIDCodeDetails_ID
Where s.MIDCodeDetails_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.MIDCodeDetails Hard Delete', @@RowCount);

--Hard Delete: FMICodeDetails
delete x
FROM [sis].[FMICodeDetails] x
left outer join [sis_stage].[FMICodeDetails] s on s.FMICodeDetails_ID = x.FMICodeDetails_ID
Where s.FMICodeDetails_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.FMICodeDetails Hard Delete', @@RowCount);

--Hard Delete: CIDCodeDetails
delete x
FROM [sis].[CIDCodeDetails] x
left outer join [sis_stage].[CIDCodeDetails] s on s.CIDCodeDetails_ID = x.CIDCodeDetails_ID
Where s.CIDCodeDetails_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CIDCodeDetails Hard Delete', @@RowCount);

--Hard Delete: CCRRepairTypes_Translation
delete x
FROM [sis].[CCRRepairTypes_Translation] x
left outer join [sis_stage].[CCRRepairTypes_Translation] s on s.CCRRepairTypes_ID = x.CCRRepairTypes_ID
Where s.CCRRepairTypes_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CCRRepairTypes_Translation Hard Delete', @@RowCount);

--Hard Delete: CCRRepairTypes
delete x
FROM [sis].[CCRRepairTypes] x
left outer join [sis_stage].[CCRRepairTypes] s on s.[RepairTypeIndicator] = x.[RepairTypeIndicator] 
			and s.SequenceNumber = x.SequenceNumber
Where s.[RepairTypeIndicator] is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CCRRepairTypes Hard Delete', @@RowCount);

--Hard Delete: RepairDescriptions_Translation
delete x
FROM [sis].[RepairDescriptions_Translation] x
left outer join [sis_stage].[RepairDescriptions_Translation] s on s.[RepairDescriptions_ID] = x.[RepairDescriptions_ID]
Where s.[RepairDescriptions_ID] is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.RepairDescriptions_Translation Hard Delete', @@RowCount);

--Hard Delete: RepairDescriptions
delete x
FROM [sis].[RepairDescriptions] x
left outer join [sis_stage].[RepairDescriptions] s on s.[RepairCode] = x.[RepairCode] 
			and s.[RepairType] = x.[RepairType]
Where s.[RepairCode] is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.RepairDescriptions Hard Delete', @@RowCount);

	--Hard Delete: IELevel_Translation
	delete x
	FROM [sis].[IELevel_Translation] x
	left outer join [sis_stage].[IELevel_Translation] s on s.[IELevel_ID] = x.[IELevel_ID]
	Where s.[IELevel_ID] is null;

	Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IELevel_Translation Hard Delete', @@RowCount);

	--Hard Delete: IELevel
	delete x
	FROM [sis].[IELevel] x
	left outer join [sis_stage].[IELevel] s on s.[IELevel_ID] = x.[IELevel_ID] 			
	Where s.[IELevel_ID] is null;


	Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.IELevel Hard Delete', @@RowCount);

--Hard Delete: TroubleshootingIllustrationDetails
delete x
FROM [sis].[TroubleshootingIllustrationDetails] x
left outer join [sis_stage].[TroubleshootingIllustrationDetails] s on s.TroubleshootingIllustrationDetails_ID = x.TroubleshootingIllustrationDetails_ID
Where s.TroubleshootingIllustrationDetails_ID is null;

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.TroubleshootingIllustrationDetails Hard Delete', @@RowCount);

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

END CATCH

END
GO
