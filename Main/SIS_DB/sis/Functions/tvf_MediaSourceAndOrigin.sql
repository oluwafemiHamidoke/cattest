CREATE FUNCTION sis.tvf_MediaSourceAndOrigin(@PART_NUMBER VARCHAR(40), @ORG_CODE VARCHAR(12))

	RETURNS @RETURN_DATASET TABLE
        ([MEDIASOURCE]    VARCHAR (12)  NOT NULL,
        [MEDIAORIGIN]     VARCHAR (12)  NOT NULL)

	AS
    BEGIN

        INSERT INTO @RETURN_DATASET
        SELECT DISTINCT M.Source AS MEDIASOURCE, MT.Media_Origin AS MEDIAORIGIN
        FROM [sis].[Media] M
        INNER JOIN [sis].[Media_Translation] MT ON M.Media_ID = MT.Media_ID
        INNER JOIN
        (
            SELECT DISTINCT 
                M.Media_Number, 
                MS.IESystemControlNumber
            FROM [sis].[MediaSequence] MS
            INNER JOIN [sis].[MediaSection] MSE ON MSE.MediaSection_ID = MS.MediaSection_ID
            INNER JOIN [sis].[Media] M ON M.Media_ID = MSE.Media_ID
            INNER JOIN [sis].[IEPart] IE ON IE.IEPart_ID = MS.IEPart_ID
            INNER JOIN [sis].[Part] P ON  IE.Part_ID = P.Part_ID
            WHERE P.Part_Number = @PART_NUMBER AND P.Org_Code = @ORG_CODE
            UNION
            SELECT DISTINCT 
                M.Media_Number, 
                MS.IESystemControlNumber
            FROM [sis].[MediaSequence] MS
            INNER JOIN [sis].[MediaSection] MSE ON MSE.MediaSection_ID = MS.MediaSection_ID
            INNER JOIN [sis].[Media] M ON M.Media_ID = MSE.Media_ID
            INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
            INNER JOIN [sis].[Part] P ON  PIR.Part_ID = P.Part_ID
            WHERE P.Part_Number = @PART_NUMBER AND P.Org_Code = @ORG_CODE
        ) part ON part.Media_Number = m.Media_Number

        RETURN;

	END;