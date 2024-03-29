﻿
/* Davide: Created 20191004 */

CREATE FUNCTION sis.tvf_ProductStructureDescriptions(@DESIRED_LANGUAGEINDICATOR VARCHAR(2)    = 'E'
												   ,@JSON                      NVARCHAR(MAX))
RETURNS @RETURN_DATASET TABLE (LANGUAGEINDICATOR           VARCHAR(2) NOT NULL
							  ,PARENTPRODUCTSTRUCTUREID    CHAR(8) NOT NULL
							  ,PRODUCTSTRUCTUREDESCRIPTION NVARCHAR(192) NOT NULL
							  ,PRODUCTSTRUCTUREID          CHAR(8) NOT NULL) 
AS
BEGIN
	DECLARE @FALLBACK_LANGUAGEINDICATOR VARCHAR(2) = 'E';

	WITH PRODUCTSTRUCTUREIDS
		 AS (SELECT PRODUCTSTRUCTUREID
			 FROM OPENJSON(@JSON) WITH(PRODUCTSTRUCTUREID CHAR(8) '$')),
		 MASPRODUCTSTRUCTURE_WITHOUT_DUPLICATE

		 /* Davide: 20191004 Due to a data error in MASPRODUCTSTRUCTURE, we need to get rid of one row */
		 AS (SELECT PS1.ID,PS1.PRODUCTSTRUCTUREID,PS1.LANGUAGEINDICATOR,PS1.PARENTPRODUCTSTRUCTUREID,PS1.PRODUCTSTRUCTUREDESCRIPTION,PS1.PARENTAGE,PS1.MISCSPNINDICATOR
			 FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE AS PS1
			 EXCEPT
			 SELECT PS2.ID,PS2.PRODUCTSTRUCTUREID,PS2.LANGUAGEINDICATOR,PS2.PARENTPRODUCTSTRUCTUREID,PS2.PRODUCTSTRUCTUREDESCRIPTION,PS2.PARENTAGE,PS2.MISCSPNINDICATOR
			 FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE AS PS2
			 WHERE PS2.PRODUCTSTRUCTUREID = '00001820' AND 
				   PS2.PARENTPRODUCTSTRUCTUREID = '00001541' AND 
				   PS2.LANGUAGEINDICATOR = 'L'),
		 FALLBACK_DATASET

		 /* Result dataset in English */
		 AS (SELECT FD.LANGUAGEINDICATOR,FD.PARENTPRODUCTSTRUCTUREID,FD.PRODUCTSTRUCTUREDESCRIPTION,FD.PRODUCTSTRUCTUREID
			 FROM MASPRODUCTSTRUCTURE_WITHOUT_DUPLICATE AS FD
			 WHERE FD.LANGUAGEINDICATOR = @FALLBACK_LANGUAGEINDICATOR AND 
				   FD.PRODUCTSTRUCTUREID IN
			 (
				 SELECT PSID.PRODUCTSTRUCTUREID
				 FROM PRODUCTSTRUCTUREIDS PSID
			 )),
		 DESIRED_DATASET

		 /* Result dataset in chosen @LANGUAGEINDICATOR language */
		 AS (SELECT DD.LANGUAGEINDICATOR,DD.PARENTPRODUCTSTRUCTUREID,DD.PRODUCTSTRUCTUREDESCRIPTION,DD.PRODUCTSTRUCTUREID
			 FROM MASPRODUCTSTRUCTURE_WITHOUT_DUPLICATE AS DD
			 WHERE DD.LANGUAGEINDICATOR = @DESIRED_LANGUAGEINDICATOR AND 
				   DD.PRODUCTSTRUCTUREID IN
			 (
				 SELECT PSID.PRODUCTSTRUCTUREID
				 FROM PRODUCTSTRUCTUREIDS PSID
			 ))
		 INSERT INTO @RETURN_DATASET (LANGUAGEINDICATOR,PARENTPRODUCTSTRUCTUREID,PRODUCTSTRUCTUREDESCRIPTION,PRODUCTSTRUCTUREID) 
				SELECT COALESCE(DD.LANGUAGEINDICATOR,FD.LANGUAGEINDICATOR) AS LANGUAGEINDICATOR,COALESCE(DD.PARENTPRODUCTSTRUCTUREID,FD.PARENTPRODUCTSTRUCTUREID) AS
				PARENTPRODUCTSTRUCTUREID,COALESCE(DD.PRODUCTSTRUCTUREDESCRIPTION,FD.PRODUCTSTRUCTUREDESCRIPTION) AS PRODUCTSTRUCTUREDESCRIPTION,COALESCE(DD.PRODUCTSTRUCTUREID,FD.
				PRODUCTSTRUCTUREID) AS PRODUCTSTRUCTUREID
				FROM DESIRED_DATASET AS DD
					 FULL OUTER JOIN FALLBACK_DATASET AS FD ON DD.PARENTPRODUCTSTRUCTUREID = FD.PARENTPRODUCTSTRUCTUREID AND 
															   DD.PRODUCTSTRUCTUREID = FD.PRODUCTSTRUCTUREID;

	RETURN;
END;