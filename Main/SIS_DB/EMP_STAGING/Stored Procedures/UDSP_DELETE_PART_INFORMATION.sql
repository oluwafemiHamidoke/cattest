CREATE PROCEDURE EMP_STAGING.UDSP_DELETE_PART_INFORMATION (@MediaNumberSystemControlNumber [dbo].UDTT_MEDIANUBERIESYSTEMCONTROLNUMBER READONLY)
AS
BEGIN
        SET NOCOUNT ON;

		DELETE tbl
			FROM [EMP_STAGING].[LNKMEDIAIEPART] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.MEDIANUMBER = input.MEDIANUMBER
			AND tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		DELETE tbl
			FROM [EMP_STAGING].[LNKCONSISTLIST] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		DELETE tbl
			FROM [EMP_STAGING].[LNKIEPSID] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.MEDIANUMBER = input.MEDIANUMBER
			AND tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		DELETE tbl
			FROM [EMP_STAGING].[LNKIEINFOTYPE] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		DELETE tbl
			FROM [EMP_STAGING].[LNKIEPRODUCTINSTANCE] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.MEDIANUMBER = input.MEDIANUMBER
			AND tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		DELETE tbl
			FROM [EMP_STAGING].[MASIMAGELOCATION] tbl
			INNER JOIN [EMP_STAGING].[LNKIEIMAGE] li
			ON tbl.GRAPHICCONTROLNUMBER = li.GRAPHICCONTROLNUMBER
			INNER JOIN @MediaNumberSystemControlNumber input
			ON li.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

		--Delete other dependant tables first
		DELETE tbl
			FROM [EMP_STAGING].[LNKIEIMAGE] tbl
			INNER JOIN  @MediaNumberSystemControlNumber input
			ON tbl.IESYSTEMCONTROLNUMBER = input.IESYSTEMCONTROLNUMBER

END;
GO