CREATE PROCEDURE [etl_stage].[UDSP_DELETE_PARTBOOK] (@MediaNumber [dbo].UDTT_MEDIANUMBER READONLY)
AS
BEGIN
    SET NOCOUNT ON;

	delete target_table from [etl_stage].Media target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].Media_Translation target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].MediaSequence target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].ProductStructure_IEPart_Relation target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].IEPart_Effective_Date target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].Media_Effectivity target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

	delete target_table from [etl_stage].Media_InfoType target_table
	inner join @MediaNumber input
	ON target_table.Media_Number = input.MEDIANUMBER

END;
GO