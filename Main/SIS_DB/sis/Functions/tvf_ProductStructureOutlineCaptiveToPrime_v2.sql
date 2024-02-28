CREATE FUNCTION sis.tvf_ProductStructureOutlineCaptiveToPrime_v2(@LANGUAGE_CODE VARCHAR(2)    = 'en'
															   ,@JSON          NVARCHAR(MAX)
															   ,@PRODUCTSTRUCTUREID int
															   ,@MEDIANUMBER VARCHAR(8))
    RETURNS @RETURN_DATASET TABLE
        (MEDIANUMBER                        VARCHAR(8)     NOT NULL
        ,IESYSTEMCONTROLNUMBER              VARCHAR(12)    NOT NULL
        ,PARENTAGE                          NUMERIC(1,0)   NOT NULL
        ,PARENTPRODUCTSTRUCTUREID           INT        NOT NULL
        ,PRODUCTSTRUCTUREID                 INT        NOT NULL
        ,INFOTYPEID                         SMALLINT       NOT NULL
        ,PARTID                             INT            NULL
        ,PARTNUMBER                         VARCHAR(50)    NULL
        ,PartName_for_NULL_PartNum          VARCHAR(50)    NULL
        ,PARTMODIFIER                       NVARCHAR(512)  NULL
        ,PARTCAPTION                        NVARCHAR(2048) NOT NULL
        ,TYPECHANGEINDICATOR                CHAR(1)        NULL
        ,isTopLevel                         BIT            NULL
        )
    AS
	BEGIN
		DECLARE @SERIALNUMBER VARCHAR(8) = (SELECT SERIALNUMBER FROM OPENJSON(@JSON) WITH(SERIALNUMBER VARCHAR(8) '$'));
		IF EXISTS(SELECT Prime_SerialNumber AS P
					FROM sis.CaptivePrime_Serial AS L
					WHERE L.Prime_SerialNumber = @SERIALNUMBER)
		BEGIN
			-- serialnumbers that appear in LNKCAPTIVETOPRIME having captive(s) enter here.

			DECLARE @PRIMESERIALNUMBER VARCHAR(8) = @SERIALNUMBER;
			DECLARE @PRIMESNP CHAR(3) = SUBSTRING(@PRIMESERIALNUMBER,1,3);
			DECLARE @PRIMESNR INT = TRY_CAST(SUBSTRING(@PRIMESERIALNUMBER,4,LEN(@PRIMESERIALNUMBER)) AS INT);

			BEGIN
                WITH CAPTIVESERIALNUMBERS(CAPTIVESERIALNUMBER
                        ,CAPTIVESNP
                        ,CAPTIVESNR)
                        AS (
                            SELECT  cps.Captive_SerialNumber,
                                sn.Serial_Number_Prefix,
                                sr.Start_Serial_Number
                            FROM sis.CaptivePrime_Serial cps
                                INNER JOIN sis.SerialNumberPrefix sn
                                    ON cps.Captive_SerialNumberPrefix_ID = sn.SerialNumberPrefix_ID
                                INNER JOIN sis.SerialNumberRange sr
                                    ON sr.SerialNumberRange_ID = cps.Captive_SerialNumberRange_ID
                            WHERE cps.Prime_SerialNumber = @PRIMESERIALNUMBER
                        ),
                IESYSTEMCONTROLNUMBERS
                AS (
                    SELECT DISTINCT ms.IESystemControlNumber FROM sis.vw_MediaSequenceFamily ms
                        WHERE
                        ms.Serial_Number_Prefix = @PRIMESNP AND
                        @PRIMESNR BETWEEN ms.Start_Serial_Number AND ms.End_Serial_Number
                        AND ms.IEPart_ID <> -1
                    ),
                MATCHING
                AS (
                    SELECT DISTINCT
                        OQ.IESystemControlNumber
                        ,CASE
                            WHEN EXISTS(SELECT C.CAPTIVESNP FROM CAPTIVESERIALNUMBERS AS C
                                        WHERE C.CAPTIVESNP = msf.Serial_Number_Prefix)
                                THEN 1 ELSE 0
                            END
                            AS HAS_CAPTIVE
                        ,(SELECT COUNT(*) FROM CAPTIVESERIALNUMBERS AS C
                            WHERE C.CAPTIVESNP = msf.Serial_Number_Prefix
                            AND C.CAPTIVESNR BETWEEN msf.Start_Serial_Number
                            AND msf.End_Serial_Number)
                            AS MATCHES_CAPTIVE
                        FROM IESYSTEMCONTROLNUMBERS AS OQ
							inner join sis.vw_MediaSequenceFamily msf
                                ON OQ.IESystemControlNumber = msf.IESystemControlNumber
                ),
                 TO_BE_REMOVED
                 AS (SELECT NQ.IESystemControlNumber FROM MATCHING AS NQ GROUP BY NQ.IESystemControlNumber
                        HAVING
                            SUM(HAS_CAPTIVE) > 0
                            AND SUM(MATCHES_CAPTIVE) = 0)
                    INSERT INTO @RETURN_DATASET
                    SELECT DISTINCT
                        F.Media_Number                    AS MEDIANUMBER
                        ,F.IESystemControlNumber          AS IESYSTEMCONTROLNUMBER
                        ,ps.Parentage                     AS PARENTAGE
                        ,ISNULL(ps.ParentProductStructure_ID, 0)     AS PARENTPRODUCTSTRUCTUREID
                        ,ps.ProductStructure_ID           AS PRODUCTSTRUCTUREID
						,mir.InfoType_ID                  AS INFOTYPEID
						,part.Part_ID                     AS PARTID
						,part.Part_Number                 AS PARTNUMBER
						,iepart.PartName_for_NULL_PartNum AS PartName_for_NULL_PartNum
						,F.Modifier                       AS PARTMODIFIER
						,F.Caption                        AS PARTCAPTION
						,msf.TypeChange_Indicator         AS TYPECHANGEINDICATOR
						,F.isTopLevel
                    FROM sis.vw_MediaSequenceFamily msf
                        INNER JOIN sis.iepart_snp_toplevel F
							ON F.Media_Number = msf.Media_Number
								AND F.IESystemControlNumber = msf.IESystemControlNumber
								AND msf.Serial_Number_Prefix = F.Serial_Number_Prefix
								AND msf.Language_ID=38 AND msf.IEPart_id != -1
						INNER JOIN sis.ProductStructure ps
							ON F.ProductStructure_ID = ps.ProductStructure_ID
						INNER JOIN sis.Media_InfoType_Relation mir
                            ON msf.Media_ID = mir.Media_ID
						INNER JOIN sis.Part part
							ON F.Part_ID = part.Part_ID
						INNER JOIN sis.IEPart iepart
							ON msf.IEPart_ID = iepart.IEPart_ID
						LEFT JOIN TO_BE_REMOVED tbr
							on (tbr.IESystemControlNumber = msf.IESystemControlNumber)
                    WHERE
                        msf.Serial_Number_Prefix = @PRIMESNP
                        AND @PRIMESNR BETWEEN msf.Start_Serial_Number AND msf.End_Serial_Number
                        AND tbr.IESystemControlNumber IS NULL
                        AND (@LANGUAGE_CODE = 'ja' OR msf.Media_Origin != 'SJ')
                        AND (@PRODUCTSTRUCTUREID IS NULL OR (ps.ProductStructure_ID  = @PRODUCTSTRUCTUREID) OR ps.ParentProductStructure_ID = @PRODUCTSTRUCTUREID )
						AND (@MEDIANUMBER IS NULL OR (F.Media_Number = @MEDIANUMBER))
            END
		END;
		ELSE
		BEGIN
			DECLARE @CAPTIVESERIALNUMBER VARCHAR(8) = @SERIALNUMBER;
			DECLARE @CAPTIVESNP CHAR(3) = SUBSTRING(@CAPTIVESERIALNUMBER,1,3);
			DECLARE @CAPTIVESNR INT = TRY_CAST(SUBSTRING(@CAPTIVESERIALNUMBER,4,LEN(@CAPTIVESERIALNUMBER)) AS INT);

			insert into @RETURN_DATASET
            SELECT DISTINCT
                    F.Media_Number                    AS MEDIANUMBER
                    ,F.IESystemControlNumber          AS IESYSTEMCONTROLNUMBER
                    ,ps.Parentage                     AS PARENTAGE
                    ,ISNULL(ps.ParentProductStructure_ID, 0)     AS PARENTPRODUCTSTRUCTUREID
                    ,ps.ProductStructure_ID           AS PRODUCTSTRUCTUREID
                    ,mir.InfoType_ID                  AS INFOTYPEID
                    ,part.Part_ID                     AS PARTID
                    ,part.Part_Number                 AS PARTNUMBER
                    ,iepart.PartName_for_NULL_PartNum AS PartName_for_NULL_PartNum
                    ,F.Modifier                       AS PARTMODIFIER
                    ,F.Caption                        AS PARTCAPTION
                    ,msf.TypeChange_Indicator         AS TYPECHANGEINDICATOR
                    ,F.isTopLevel
                FROM
                    sis.vw_MediaSequenceFamily msf
                        INNER JOIN sis.iepart_snp_toplevel F
							ON F.Media_Number = msf.Media_Number
								AND F.IESystemControlNumber = msf.IESystemControlNumber
								AND msf.Serial_Number_Prefix = F.Serial_Number_Prefix
								AND msf.Language_ID=38 AND msf.IEPart_id != -1
					    INNER JOIN sis.ProductStructure ps
					        ON F.ProductStructure_ID = ps.ProductStructure_ID
						INNER JOIN sis.Media_InfoType_Relation mir
                            ON msf.Media_ID = mir.Media_ID
						INNER JOIN sis.Part part
							ON F.Part_ID = part.Part_ID
						INNER JOIN sis.IEPart iepart
							ON msf.IEPart_ID = iepart.IEPart_ID
                WHERE
                        msf.Serial_Number_Prefix = @CAPTIVESNP
                        AND @CAPTIVESNR BETWEEN msf.Start_Serial_Number AND msf.End_Serial_Number
                        AND (@LANGUAGE_CODE = 'ja' OR msf.Media_Origin != 'SJ')
                        AND (@PRODUCTSTRUCTUREID IS NULL OR (ps.ProductStructure_ID  = @PRODUCTSTRUCTUREID) OR ps.ParentProductStructure_ID = @PRODUCTSTRUCTUREID )
						AND (@MEDIANUMBER IS NULL OR (F.Media_Number = @MEDIANUMBER))
		END;

		RETURN;
	END;