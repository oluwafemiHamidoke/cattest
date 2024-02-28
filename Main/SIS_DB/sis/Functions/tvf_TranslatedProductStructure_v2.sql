﻿
/* Davide: Created 20200305 https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/5883/ */
/* Davide: Modified 20200320 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5968/ */

CREATE FUNCTION sis.tvf_TranslatedProductStructure_v2(@LANGUAGE_CODE VARCHAR(2)    = 'en'
													,@JSON          NVARCHAR(MAX))
RETURNS @RETURN_DATASET TABLE
	(LANGUAGE_CODE               VARCHAR(2) NOT NULL
	,PARENTPRODUCTSTRUCTUREID    INT NULL
	,PRODUCTSTRUCTUREDESCRIPTION NVARCHAR(250) NOT NULL
	,PRODUCTSTRUCTUREID          INT NOT NULL) 
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

		WITH PRODUCTSTRUCTUREIDS(PRODUCTSTRUCTUREID)
			 AS (SELECT PRODUCTSTRUCTUREID FROM OPENJSON(@JSON) WITH(PRODUCTSTRUCTUREID INT '$')),
			 FALLBACK_DATASET
			 AS (SELECT L.Language_Code AS              LANGUAGE_CODE
					   ,PS.ParentProductStructure_ID AS PARENTPRODUCTSTRUCTUREID
					   ,PST.Description AS              PRODUCTSTRUCTUREDESCRIPTION
					   ,PST.ProductStructure_ID AS      PRODUCTSTRUCTUREID
				   FROM sis.ProductStructure AS PS
						JOIN sis.ProductStructure_Translation AS PST ON PST.ProductStructure_ID = PS.ProductStructure_ID
						JOIN sis.Language AS L ON L.Language_ID = PST.Language_ID
				   WHERE
						 PST.Language_ID = @FALLBACK_LANGUAGEID
						 AND PST.ProductStructure_ID IN(SELECT I.PRODUCTSTRUCTUREID FROM PRODUCTSTRUCTUREIDS AS I)),
			 DESIRED_DATASET
			 AS (SELECT L.Language_Code AS              LANGUAGE_CODE
					   ,PS.ParentProductStructure_ID AS PARENTPRODUCTSTRUCTUREID
					   ,PST.Description AS              PRODUCTSTRUCTUREDESCRIPTION
					   ,PST.ProductStructure_ID AS      PRODUCTSTRUCTUREID
				   FROM sis.ProductStructure AS PS
						JOIN sis.ProductStructure_Translation AS PST ON PST.ProductStructure_ID = PS.ProductStructure_ID
						JOIN sis.Language AS L ON L.Language_ID = PST.Language_ID
				   WHERE
						 PST.Language_ID = @DESIRED_LANGUAGEID
						 AND PST.ProductStructure_ID IN(SELECT I.PRODUCTSTRUCTUREID FROM PRODUCTSTRUCTUREIDS AS I))
			 INSERT INTO @RETURN_DATASET
			 SELECT COALESCE(DD.LANGUAGE_CODE,FD.LANGUAGE_CODE) AS                             LANGUAGE_CODE
				   ,COALESCE(DD.PARENTPRODUCTSTRUCTUREID,FD.PARENTPRODUCTSTRUCTUREID,0) AS     PARENTPRODUCTSTRUCTUREID
				   ,COALESCE(DD.PRODUCTSTRUCTUREDESCRIPTION,FD.PRODUCTSTRUCTUREDESCRIPTION) AS PRODUCTSTRUCTUREDESCRIPTION
				   ,COALESCE(DD.PRODUCTSTRUCTUREID,FD.PRODUCTSTRUCTUREID) AS                   PRODUCTSTRUCTUREID
			   FROM DESIRED_DATASET AS DD
					FULL OUTER JOIN FALLBACK_DATASET AS FD ON FD.PRODUCTSTRUCTUREID = DD.PRODUCTSTRUCTUREID;

		RETURN;
	END;
GO
