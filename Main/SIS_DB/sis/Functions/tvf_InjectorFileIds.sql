-- =============================================
-- Author:      Ramesh Ramalingam
-- Create Date: 20210218
-- Description: Fetches the list of matching injector files for given serial numers
-- =============================================
CREATE FUNCTION sis.tvf_InjectorFileIds(@SERIAL_NUMBER VARCHAR(8000))
RETURNS TABLE
AS
RETURN
    with SNLIST (SerialNumber) as (SELECT value FROM STRING_SPLIT(@SERIAL_NUMBER,','))
    Select SC.ServiceFile_ID from sis.ServiceFile_SearchCriteria as SC
    inner join SNLIST on SC.Value = SNLIST.SerialNumber where (SC.InfoType_ID = 55 or SC.InfoType_ID = 63) and SC.Search_Type = 'SN';