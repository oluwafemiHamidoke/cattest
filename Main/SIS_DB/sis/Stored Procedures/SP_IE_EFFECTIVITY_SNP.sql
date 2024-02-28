-- =============================================
-- Author:      Venkatesh B S
-- Create Date: 20230907
-- Description: Fetch IE_ID's from sis.IE_Effectivity for the given prefix and IE_ID list retrieved from sis.IE table
-- =============================================
CREATE PROCEDURE [sis].[SP_IE_EFFECTIVITY_SNP]
    (@SNP VARCHAR(60),
    @IE_ID_List VARCHAR(MAX))

AS

BEGIN
    SET NOCOUNT ON
    DROP TABLE IF EXISTS #t1;
    DROP TABLE IF EXISTS #t2;


    SELECT CAST(value as INT) IE_ID
    INTO #t1
    FROM STRING_SPLIT(@IE_ID_List, ',');

    SELECT DISTINCT ieeffectiv9_.IE_ID
    INTO #t2
    FROM sis.IE_Effectivity ieeffectiv9_ 
    INNER JOIN sis.SerialNumberPrefix serialnumb6_ ON (ieeffectiv9_.SerialNumberPrefix_ID=serialnumb6_.SerialNumberPrefix_ID 
    AND Serial_Number_Prefix=@SNP)

    SELECT DISTINCT ie_effec.IE_ID
    FROM #t1 input_ie 
    INNER JOIN #t2 AS ie_effec ON (input_ie.IE_ID = ie_effec.IE_ID)

END
GO