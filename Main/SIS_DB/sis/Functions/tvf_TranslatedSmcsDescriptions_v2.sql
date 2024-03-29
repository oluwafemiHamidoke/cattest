
/* Davide: Created 20191023 */
/* Modified By: Kishor Padmanabhan
 * Modified Date: 20220901
 * Modified Reason: Use New Data Model for SMCS Desciptions
 * Associated User Story: 22457
*/

CREATE FUNCTION sis.tvf_TranslatedSmcsDescriptions_v2(@DESIRED_LANGUAGEINDICATOR VARCHAR(2)    = 'E'
												 ,@JSON                      NVARCHAR(MAX))
RETURNS @RETURN_DATASET TABLE
	(LANGUAGEINDICATOR VARCHAR(2) NOT NULL
	,SMCSCOMPCODE      CHAR(4) NOT NULL
	,SMCSDESCRIPTION   NVARCHAR(192) NOT NULL) 
AS
	BEGIN
		DECLARE @FALLBACK_LANGUAGEINDICATOR VARCHAR(2) = 'E';

		WITH SMCSCOMPCODES
			 AS (SELECT SMCSCOMPCODE FROM OPENJSON(@JSON) WITH(SMCSCOMPCODE CHAR(4) '$')),
			 FALLBACK_DATASET
			 AS (SELECT L.Legacy_Language_Indicator AS LANGUAGEINDICATOR
					   ,S.SMCSCOMPCODE
					   ,ST.Description AS SMCSDESCRIPTION
				   FROM sis.SMCS AS S
				   INNER JOIN sis.SMCS_Translation ST ON S.SMCS_ID = ST.SMCS_ID
				   INNER JOIN sis.Language L ON L.Language_ID = ST.Language_ID
				   WHERE
						 L.Legacy_Language_Indicator = @FALLBACK_LANGUAGEINDICATOR
						 AND S.SMCSCOMPCODE IN
					 (SELECT I.SMCSCOMPCODE FROM SMCSCOMPCODES AS I) ),
			 DESIRED_DATASET
			 AS (SELECT L.Legacy_Language_Indicator AS LANGUAGEINDICATOR
					   ,S.SMCSCOMPCODE
					   ,ST.Description AS SMCSDESCRIPTION
				   FROM sis.SMCS AS S
				   INNER JOIN sis.SMCS_Translation ST ON S.SMCS_ID = ST.SMCS_ID
				   INNER JOIN sis.Language L ON L.Language_ID = ST.Language_ID
				   WHERE
						 L.Legacy_Language_Indicator = @DESIRED_LANGUAGEINDICATOR
						 AND S.SMCSCOMPCODE IN
					 (SELECT I.SMCSCOMPCODE FROM SMCSCOMPCODES AS I) )
			 INSERT INTO @RETURN_DATASET
			 SELECT COALESCE(DD.LANGUAGEINDICATOR,FD.LANGUAGEINDICATOR) AS LANGUAGEINDICATOR
				   ,COALESCE(DD.SMCSCOMPCODE,FD.SMCSCOMPCODE) AS           SMCSCOMPCODE
				   ,COALESCE(DD.SMCSDESCRIPTION,FD.SMCSDESCRIPTION) AS     SMCSDESCRIPTION
			   FROM DESIRED_DATASET AS DD
					FULL OUTER JOIN FALLBACK_DATASET AS FD ON FD.SMCSCOMPCODE = DD.SMCSCOMPCODE;

		RETURN;
	END;