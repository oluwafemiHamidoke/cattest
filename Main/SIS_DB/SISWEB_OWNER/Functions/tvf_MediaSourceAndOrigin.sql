CREATE FUNCTION SISWEB_OWNER.tvf_MediaSourceAndOrigin(@PART_NUMBER VARCHAR(40), @ORG_CODE VARCHAR(12))

	RETURNS @RETURN_DATASET TABLE
        ([MEDIASOURCE]    VARCHAR (12)  NOT NULL,
        [MEDIAORIGIN]     VARCHAR (12)  NOT NULL)

	AS BEGIN

	INSERT INTO @RETURN_DATASET
		SELECT DISTINCT m.MEDIASOURCE, m.MEDIAORIGIN FROM SISWEB_OWNER.MASMEDIA m
		INNER JOIN
		(SELECT DISTINCT p.MEDIANUMBER, p.IESYSTEMCONTROLNUMBER FROM SISWEB_OWNER.LNKMEDIAIEPART p
		WHERE p.IEPARTNUMBER = @PART_NUMBER and p.ORGCODE= @ORG_CODE
		UNION
		SELECT DISTINCT p.MEDIANUMBER, c.IESYSTEMCONTROLNUMBER FROM SISWEB_OWNER.LNKMEDIAIEPART p
			INNER JOIN SISWEB_OWNER.LNKCONSISTLIST c ON p.IESYSTEMCONTROLNUMBER = c.IESYSTEMCONTROLNUMBER
		WHERE c.PARTNUMBER = @PART_NUMBER and c.ORGCODE = @ORG_CODE) part ON part.MEDIANUMBER = m.MEDIANUMBER

	RETURN;

	END;