CREATE FUNCTION sis.tvf_TranslatedSupersessionChains_v2(@LANGUAGE_CODE VARCHAR(2)  = 'en'
												   ,@PART_NUMBER   VARCHAR(50)
												   ,@ORG_CODE      VARCHAR(12))
RETURNS @RETURN_DATASET TABLE (SUPERSESSIONCHAIN_ID         INT NOT NULL
							  ,TRANSLATED_SUPERSESSIONCHAIN NVARCHAR(MAX) NOT NULL) 
AS
BEGIN
	DECLARE @FALLBACK_LANGUAGEID INT
		   ,@DESIRED_LANGUAGEID  INT
           ,@ORGCODE_SEPARATOR VARCHAR(1) = sis.fn_GetDefaultORGCODESeparator()
		   ,@DEFAULT_ORGCODE VARCHAR(12) = sis.fn_GetDefaultORGCODE();

	DECLARE @SUPERSESSIONCHAINIDS TABLE (SupersessionChain_ID INT PRIMARY KEY);
	DECLARE @SUPERSESSIONCHAINS TABLE (SupersessionChain_ID INT
									  ,SupersessionChain    VARCHAR(8000));
	DECLARE @PART_NUMBERS AS TABLE (SupersessionChain_ID INT
									--,SupersessionChain    VARCHAR(8000)
								   ,jKey                 INT --PRIMARY KEY
								   ,Part_Number          VARCHAR(50)
								   ,Org_Code             VARCHAR(12)
								   ,PRIMARY KEY(SupersessionChain_ID,Part_Number, Org_Code));

	SELECT @FALLBACK_LANGUAGEID = L.Language_ID
	FROM sis.Language AS L
	WHERE L.Language_Code = 'en' AND 
		  L.Default_Language = 1;
	SELECT @DESIRED_LANGUAGEID = L.Language_ID
	FROM sis.Language AS L
	WHERE L.Language_Code = @LANGUAGE_CODE AND 
		  L.Default_Language = 1;

	INSERT INTO @SUPERSESSIONCHAINIDS
		   SELECT SPR.SupersessionChain_ID
		   FROM sis.SupersessionChain_Part_Relation AS SPR
		   WHERE Part_ID = (SELECT P.Part_ID FROM sis.Part AS P WHERE P.Part_Number = @PART_NUMBER AND P.Org_Code = @ORG_CODE);

	INSERT INTO @SUPERSESSIONCHAINS
		   SELECT SC.SupersessionChain_ID,SC.SupersessionChain
		   FROM sis.SupersessionChain AS SC
		   WHERE SC.SupersessionChain_ID IN(SELECT IDS.SupersessionChain_ID FROM @SUPERSESSIONCHAINIDS AS IDS);

	INSERT INTO @PART_NUMBERS
		   SELECT SC.SupersessionChain_ID
		   --,SC.SupersessionChain
		   ,J.[key], sis.fn_GetPartNumberBySeparator(J.[value],@ORGCODE_SEPARATOR),
               sis.fn_GetOrgCodeBySeparator(J.[value],@ORGCODE_SEPARATOR,@DEFAULT_ORGCODE)
		   FROM @SUPERSESSIONCHAINS AS SC
				CROSS APPLY OPENJSON(sis.fn_SupersessionChain_to_JSON (SC.SupersessionChain),'strict $') AS J;

	INSERT INTO @RETURN_DATASET
		   SELECT PN.SupersessionChain_ID
		   --,SupersessionChain
		   ,TRANSLATED_SUPERSESSIONCHAIN = STRING_AGG(PN.Part_Number + @ORGCODE_SEPARATOR + PN.Org_Code + ' ' + COALESCE(PT.Part_Name,PTT.Part_Name,'--'),'|')
		   WITHIN GROUP (ORDER BY PN.jKey ASC)
		   FROM sis.Part AS P
				JOIN @PART_NUMBERS AS PN ON PN.Part_Number = P.Part_Number AND
                                            PN.Org_Code    = P.Org_Code
				LEFT JOIN sis.Part_Translation AS PT ON PT.Part_ID = P.Part_ID AND
														PT.Language_ID = @DESIRED_LANGUAGEID
				LEFT JOIN sis.Part_Translation AS PTT ON PTT.Part_ID = P.Part_ID AND 
														 PTT.Language_ID = @FALLBACK_LANGUAGEID
		   GROUP BY PN.SupersessionChain_ID;
	--,PN.SupersessionChain;

	RETURN;
END;
