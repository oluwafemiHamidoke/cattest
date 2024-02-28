
/* Davide: Created 20200304 https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/5883/ */
-- Modify date:	2020-03-16 Removed natural Key InfoTypeID
/* Davide: Modified 20200320 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5968/ */

CREATE FUNCTION [sis].[tvf_TranslatedInfoTypes_v2](@LANGUAGE_CODE VARCHAR(2)    = 'en'
											 ,@JSON          NVARCHAR(MAX))
RETURNS @RETURN_DATASET TABLE
	(INFOTYPEID          NUMERIC(3,0) NOT NULL
	,LANGUAGE_CODE       VARCHAR(2) NOT NULL
	,INFORMATIONTYPEDESC NVARCHAR(720) NOT NULL) 
AS
	BEGIN
		DECLARE @FALLBACK_LANGUAGEID INT
			   ,@DESIRED_LANGUAGEID  INT;
		SELECT @FALLBACK_LANGUAGEID = L.Language_ID
		  FROM sis.Language AS L
		  WHERE
				L.Language_Code = 'en'
				AND L.Default_Language = 1;
		SELECT @DESIRED_LANGUAGEID = L.Language_ID
		  FROM sis.Language AS L
		  WHERE
				L.Language_Code = @LANGUAGE_CODE
				AND L.Default_Language = 1;

		WITH INFOTYPEIDS(INFOTYPEID)
			 AS (SELECT INFOTYPEID FROM OPENJSON(@JSON) WITH(INFOTYPEID NUMERIC(3,0) '$')),
			 FALLBACK_DATASET
			 AS (SELECT IT.InfoType_ID AS  INFOTYPEID
					   ,L.Language_Code AS LANGUAGE_CODE
					   ,ITT.Description AS INFORMATIONTYPEDESC
				   FROM sis.InfoType AS IT
						JOIN sis.InfoType_Translation AS ITT ON IT.InfoType_ID = ITT.InfoType_ID
						JOIN sis.Language AS L ON L.Language_ID = ITT.Language_ID
				   WHERE
						 ITT.Language_ID = @FALLBACK_LANGUAGEID
						 AND IT.InfoType_ID IN(SELECT I.INFOTYPEID FROM INFOTYPEIDS AS I)),
			 DESIRED_DATASET
			 AS (SELECT IT.InfoType_ID AS  INFOTYPEID
					   ,L.Language_Code AS LANGUAGE_CODE
					   ,ITT.Description AS INFORMATIONTYPEDESC
				   FROM sis.InfoType AS IT
						JOIN sis.InfoType_Translation AS ITT ON IT.InfoType_ID = ITT.InfoType_ID
						JOIN sis.Language AS L ON L.Language_ID = ITT.Language_ID
				   WHERE
						 ITT.Language_ID = @DESIRED_LANGUAGEID
						 AND IT.InfoType_ID IN(SELECT I.INFOTYPEID FROM INFOTYPEIDS AS I))
			 INSERT INTO @RETURN_DATASET
					(INFOTYPEID
					,LANGUAGE_CODE
					,INFORMATIONTYPEDESC
					) 
			 SELECT COALESCE(DD.INFOTYPEID,FD.INFOTYPEID) AS                   INFOTYPEID
				   ,COALESCE(DD.LANGUAGE_CODE,FD.LANGUAGE_CODE) AS             LANGUAGE_CODE
				   ,COALESCE(DD.INFORMATIONTYPEDESC,FD.INFORMATIONTYPEDESC) AS INFORMATIONTYPEDESC
			   FROM DESIRED_DATASET AS DD
					FULL OUTER JOIN FALLBACK_DATASET AS FD ON DD.INFOTYPEID = FD.INFOTYPEID;
		RETURN;
	END;
GO

