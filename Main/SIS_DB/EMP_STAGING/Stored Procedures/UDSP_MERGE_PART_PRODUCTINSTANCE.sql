CREATE PROCEDURE EMP_STAGING.UDSP_MERGE_PART_PRODUCTINSTANCE
(@productinstance [dbo].UDTT_PRODUCTINSTANCE_INSERT_IN READONLY, @ProductFamilyNumber VARCHAR(60))
AS BEGIN
SET NOCOUNT ON;

delete x
from [EMP_STAGING].[LNKIEPRODUCTINSTANCE] x
INNER JOIN @productinstance s
on s.MEDIANUMBER = x.MEDIANUMBER and s.IESYSTEMCONTROLNUMBER = x.IESYSTEMCONTROLNUMBER


MERGE INTO
    [EMP_STAGING].[LNKIEPRODUCTINSTANCE] t
USING
	(SELECT s.[MEDIANUMBER], s.[IESYSTEMCONTROLNUMBER], pi.[EMPPRODUCTINSTANCE_ID]
    FROM [EMP_STAGING].[EMPPRODUCTFAMILY] pf
        INNER JOIN [EMP_STAGING].[EMPSALESMODEL] sm ON sm.[EMPPRODUCTFAMILY_ID] = pf.[EMPPRODUCTFAMILY_ID] AND pf.[NUMBER] = @ProductFamilyNumber
        INNER JOIN [EMP_STAGING].[EMPPRODUCTINSTANCE] pi ON pi.[EMPSALESMODEL_ID] = sm.[EMPSALESMODEL_ID]
		INNER JOIN @productinstance s on pi.[NUMBER] = s.[NUMBER]) source
	ON
    t.[MEDIANUMBER] = source.[MEDIANUMBER] AND t.[IESYSTEMCONTROLNUMBER] = source.[IESYSTEMCONTROLNUMBER]
	AND t.[EMPPRODUCTINSTANCE_ID] = source.[EMPPRODUCTINSTANCE_ID]
WHEN NOT MATCHED THEN
    INSERT VALUES (source.[MEDIANUMBER], source.[IESYSTEMCONTROLNUMBER], source.[EMPPRODUCTINSTANCE_ID]);

END