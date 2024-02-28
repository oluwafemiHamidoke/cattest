﻿
/* Davide: Created  20200929 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/7602/ */
/* Davide: Modified 20201028 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/8236/ */
/* Davide: Modified 20201102 https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/8238/ */

CREATE FUNCTION sis.tvf_Serial_Number_Filtration_Logic_v1(@MEDIANUMBER VARCHAR(8)  = NULL
														,@SNP         VARCHAR(10) = NULL
														,@SNR         INT         = NULL
														,@PSID        VARCHAR(8)  = NULL)
RETURNS @RETURN_DATASET TABLE (IESYSTEMCONTROLNUMBER VARCHAR(12)) 
AS
BEGIN

	RETURN; -- Davide 20201124: we are testing the NULL returned by the TVF to fix performance issues
	--DECLARE @INITIAL_DATASET TABLE (IESYSTEMCONTROLNUMBER VARCHAR(12));
	--DECLARE @INTERMEDIATE_DATASET TABLE
	--	(IESYSTEMCONTROLNUMBER VARCHAR(12) NULL
	--	,MEDIANUMBER           VARCHAR(8)
	--	,PSID                  VARCHAR(8));
	--DECLARE @SERIALNUMBER VARCHAR(8);
	--SET @SERIALNUMBER = @SNP + CAST(FORMAT(@SNR,'00000') AS VARCHAR);
	--IF @SNP IS NULL
	--	RETURN;
	--IF @SNR IS NULL
	--	RETURN;
	---- lookup the SNP in LNKPRODUCT to get the product code.
	--IF EXISTS(SELECT P.PRODUCTCODE
	--			FROM SISWEB_OWNER.LNKPRODUCT AS P
	--			WHERE
	--				  P.SNP = @SNP
	--				  AND P.PRODUCTCODE IN ('EMAC','EPG','EPG2','IENG','MENG','TENG','VENG') )
	--BEGIN
	--	-- IT IS AN ENGINE
	--	--
	--	INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--	SELECT TB.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER
	--	  FROM SISWEB_OWNER.LNKASSHIPPEDCONSIST AS TA
	--		   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TB ON TB.IEPARTNUMBER = TA.PARTNUMBER
	--	  WHERE TA.SERIALNUMBER = @SERIALNUMBER;
	--	--
	--	INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--	SELECT TCC.RELATEDIESCN AS IESYSTEMCONTROLNUMBER
	--	  FROM SISWEB_OWNER.LNKASSHIPPEDCONSIST AS TAA
	--		   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TBB ON TBB.IEPARTNUMBER = TAA.PARTNUMBER
	--		   JOIN SISWEB_OWNER.LNKRELATEDPARTIES AS TCC ON TCC.IESCN = TBB.IESYSTEMCONTROLNUMBER
	--	  WHERE TAA.SERIALNUMBER = @SERIALNUMBER;
	--	--
	--END;
	--ELSE
	--BEGIN
	--	--
	--	INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--	SELECT TB.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER
	--	  FROM SISWEB_OWNER.LNKASSHIPPEDPRODUCTDETAILS AS TA
	--		   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TB ON TB.IEPARTNUMBER = TA.PARTNUMBER
	--	  WHERE TA.SERIALNUMBER = @SERIALNUMBER;
	--	--UNION
	--	INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--	SELECT TCC.RELATEDIESCN AS IESYSTEMCONTROLNUMBER
	--	  FROM SISWEB_OWNER.LNKASSHIPPEDPRODUCTDETAILS AS TAA
	--		   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TBB ON TBB.IEPARTNUMBER = TAA.PARTNUMBER
	--		   JOIN SISWEB_OWNER.LNKRELATEDPARTIES AS TCC ON TCC.IESCN = TBB.IESYSTEMCONTROLNUMBER
	--	  WHERE TAA.SERIALNUMBER = @SERIALNUMBER;
	--	--UNION
	--END;
	--INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--SELECT TY.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER
	--  FROM SISWEB_OWNER.LNKASSHIPPEDCONSIST AS TX
	--	   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TY ON TY.IEPARTNUMBER = TX.PARTNUMBER
	--	   JOIN SISWEB_OWNER.LNKCAPTIVETOPRIME AS TZ ON TX.SERIALNUMBER = TZ.CAPTIVESERIALNUMBER
	--  WHERE
	--		TZ.PRIMESERIALNUMBER = @SERIALNUMBER
	--		AND TZ.ATTACHMENTTYPE = 'EN'
	--		AND TX.ENGGCHANGELEVELNO <> ' F';
	----UNION
	--INSERT INTO @INITIAL_DATASET (IESYSTEMCONTROLNUMBER) 
	--SELECT TZZ.RELATEDIESCN AS IESYSTEMCONTROLNUMBER
	--  FROM SISWEB_OWNER.LNKASSHIPPEDCONSIST AS TXX
	--	   JOIN SISWEB_OWNER.LNKMEDIAIEPART AS TYY ON TYY.IEPARTNUMBER = TXX.PARTNUMBER
	--	   JOIN SISWEB_OWNER.LNKRELATEDPARTIES AS TZZ ON TZZ.IESCN = TYY.IESYSTEMCONTROLNUMBER
	--	   JOIN SISWEB_OWNER.LNKCAPTIVETOPRIME AS TVV ON TXX.SERIALNUMBER = TVV.CAPTIVESERIALNUMBER
	--  WHERE
	--		TVV.PRIMESERIALNUMBER = @SERIALNUMBER
	--		AND TVV.ATTACHMENTTYPE = 'EN';
	--INSERT INTO @INTERMEDIATE_DATASET
	--	   (IESYSTEMCONTROLNUMBER
	--	   ,MEDIANUMBER
	--	   ,PSID
	--	   ) 
	--SELECT A.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER
	--	  ,A.MEDIANUMBER AS           MEDIANUMBER
	--	  ,A.PSID AS                  PSID
	--  FROM SISWEB_OWNER.LNKIEPSID AS A
	--	   JOIN SISWEB_OWNER.LNKIEINFOTYPE AS B ON B.IESYSTEMCONTROLNUMBER = A.IESYSTEMCONTROLNUMBER
	--	   JOIN SISWEB_OWNER.LNKIESNP AS C ON C.IESYSTEMCONTROLNUMBER = B.IESYSTEMCONTROLNUMBER
	--	   JOIN(SELECT DISTINCT 
	--				   IE.IESYSTEMCONTROLNUMBER FROM @INITIAL_DATASET AS IE) AS D ON C.IESYSTEMCONTROLNUMBER = D.IESYSTEMCONTROLNUMBER
	--  WHERE
	--		C.MEDIANUMBER = A.MEDIANUMBER
	--		AND C.SNP = @SNP
	--		AND C.TYPEINDICATOR = 'S'
	--		AND C.PBINDICATOR = 'Y'
	--		AND @SNR BETWEEN C.BEGINNINGRANGE AND C.ENDRANGE;
	--IF @MEDIANUMBER IS NULL
	--BEGIN
	--	IF @PSID IS NULL
	--	BEGIN
	--		/*@MEDIANUMBER IS NULL @PSID IS NULL*/
	--		INSERT INTO @RETURN_DATASET (IESYSTEMCONTROLNUMBER) 
	--		SELECT IESYSTEMCONTROLNUMBER FROM @INTERMEDIATE_DATASET;
	--	END;
	--	ELSE
	--	/*@MEDIANUMBER IS NULL @PSID IS NOT NULL*/
	--	BEGIN
	--		INSERT INTO @RETURN_DATASET (IESYSTEMCONTROLNUMBER) 
	--		SELECT IESYSTEMCONTROLNUMBER FROM @INTERMEDIATE_DATASET WHERE PSID = @PSID;
	--	END;
	--END;
	--ELSE
	--BEGIN
	--	IF @PSID IS NULL
	--	BEGIN
	--		/*@MEDIANUMBER IS NOT NULL @PSID IS NULL*/
	--		INSERT INTO @RETURN_DATASET (IESYSTEMCONTROLNUMBER) 
	--		SELECT IESYSTEMCONTROLNUMBER FROM @INTERMEDIATE_DATASET WHERE MEDIANUMBER = @MEDIANUMBER;
	--	END;
	--	ELSE
	--	/*@MEDIANUMBER IS NOT NULL @PSID IS NOT NULL*/
	--	BEGIN
	--		INSERT INTO @RETURN_DATASET (IESYSTEMCONTROLNUMBER) 
	--		SELECT IESYSTEMCONTROLNUMBER FROM @INTERMEDIATE_DATASET WHERE
	--																	  MEDIANUMBER = @MEDIANUMBER
	--																	  AND PSID = @PSID;
	--	END;
	--END;
	--RETURN;
END;