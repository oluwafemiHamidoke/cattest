-- =============================================
-- Author:      Ramesh Ramalingam
-- Create Date: 20210312
-- Update Date: 20230608
-- Updated By: Prashant Shrivastava
-- Description: Fetches the list of matching service software file details (https://sis-cat-com.visualstudio.com/CAT-App-Retirement/_workitems/edit/10475)
-- =============================================
CREATE FUNCTION sis.tvf_ServiceSoftwareFile_Details(@SERVICEFILE_IDS           VARCHAR(8000)
                                                  , @LANGUAGE_ID               INT
                                                  , @DEFAULT_LANGUAGE_ID       INT
                                                  , @IS_FLASH_FILES            BIT
												  , @SNP                       VARCHAR (10)
												  , @RANGE                     INT)
RETURNS @RETURN_DATASET TABLE
	(
        ServiceFile_ID                  INT             NOT NULL
        ,ServiceFile_Name               NVARCHAR(100)   NULL
        ,InfoType_ID                    INT             NOT NULL
        ,ServiceFile_Size               INT             NULL
        ,ECM_Description                NVARCHAR (720)  NULL
        ,Referred_ServiceFile_ID        INT             NULL
        ,ECM_Description_Language_ID    INT             NULL
        ,Available_Flag                 VARCHAR(1)      NULL
        ,Is_Engine_Related              BIT             NOT NULL
        ,Is_TelematicsFlash_Found       BIT             NOT NULL
    )
AS
BEGIN
        DECLARE @temp_endRange TABLE (Num_Data int, End_Range int, ServiceFile_ID int) INSERT INTO @temp_endRange
        Select Distinct SC.Num_Data,SC.End_Range as End_Range,SC.ServiceFile_ID
		from sis.ServiceFile_SearchCriteria AS SC
		Inner join ( SELECT MAX(SC1.End_Range) as End_Range,SC1.ServiceFile_ID as ServiceFile_ID
            		FROM sis.ServiceFile_SearchCriteria AS SC1
                	WHERE SC1.Search_Value = @SNP AND SC1.InfoType_ID = 41 AND SC1.Search_Type = 'SN'
                	GROUP BY SC1.Search_Value,SC1.ServiceFile_ID) SC2
		on SC2.ServiceFile_ID=SC.ServiceFile_ID and SC2.End_Range=SC.End_Range
		where  SC.Search_Value = @SNP AND SC.InfoType_ID = 41 AND SC.Search_Type = 'SN'

        DECLARE @ServiceFiles TABLE(
            ServiceFile_ID INT,
            ServiceFile_Name VARCHAR(100),
            InfoType_ID INT,
            ServiceFile_Size INT,
			Available_Flag VARCHAR(1)
        );
            INSERT INTO @ServiceFiles
            SELECT S.ServiceFile_ID, S.ServiceFile_Name, S.InfoType_ID, S.ServiceFile_Size, S.Available_Flag
            FROM sis.ServiceFile AS S
            INNER JOIN (SELECT DISTINCT value FROM STRING_SPLIT(@SERVICEFILE_IDS,',')) AS IDLIST ON S.ServiceFile_ID = IDLIST.value
            WHERE S.Available_Flag in('Y','R');

        IF (@IS_FLASH_FILES = 0)
            INSERT INTO @RETURN_DATASET
            SELECT ServiceFile_ID
                 , ServiceFile_Name
                 , InfoType_ID
                 , ServiceFile_Size
                 , NULL AS ECM_Description
                 , NULL AS Referred_ServiceFile_ID
                 , NULL AS Language_ID
                 , Available_Flag AS Available_Flag
                 , 0 AS Is_Engine_Related
                 , 0 AS Is_TelematicsFlash_Found 
    
            from @ServiceFiles

        ELSE IF(@SNP is not NULL)
            INSERT INTO @RETURN_DATASET
                SELECT DISTINCT T.ServiceFile_ID
                              , T.ServiceFile_Name
                              , T.InfoType_ID
                              , T.ServiceFile_Size
                              , COALESCE(FA_T.[Description],FA_EN.[Description] ) AS ECM_Description
                              , SR.Referred_ServiceFile_ID
                              , COALESCE(FA_T.Language_ID,FA_EN.Language_ID) AS ECM_Description_Language_ID
                              , T.Available_Flag
                              , COALESCE(FA.Is_Engine_Related, 0) AS Is_Engine_Related
                              , CASE WHEN UPPER(COALESCE(FA_T.[Description],FA_EN.[Description] )) LIKE '%TELEMATICS%' THEN 1 ELSE 0 END AS Is_TelematicsFlash_Found
               
                FROM @ServiceFiles AS T
                --LEFT JOIN sis.ServiceFile_DisplayTerms as SD ON SD.ServiceFile_ID = T.ServiceFile_ID
                --LEFT JOIN sis.ServiceFile_DisplayTerms_Translation as ST on SD.ServiceFile_DisplayTerms_ID = ST.ServiceFile_DisplayTerms_ID
                LEFT JOIN @temp_endRange SSC on SSC.ServiceFile_ID=T.ServiceFile_ID 
                LEFT JOIN sis.FlashApplication AS FA ON FA.FlashApplication_ID =  SSC.Num_Data
                LEFT JOIN sis.FlashApplication_Translation AS FA_T ON FA_T.FlashApplication_ID =  FA.FlashApplication_ID
                                               AND FA_T.Language_ID = @LANGUAGE_ID
                LEFT JOIN sis.FlashApplication_Translation AS FA_EN ON FA_EN.FlashApplication_ID = FA.FlashApplication_ID
                                                AND FA_EN.Language_ID = @DEFAULT_LANGUAGE_ID
                LEFT JOIN sis.ServiceFile_Reference AS SR ON SR.ServiceFile_ID = T.ServiceFile_ID

        ELSE
                INSERT INTO @RETURN_DATASET
                    SELECT DISTINCT T.ServiceFile_ID
                                  , T.ServiceFile_Name
                                  , T.InfoType_ID
                                  , T.ServiceFile_Size
                                  , COALESCE(FA_T.[Description],FA_EN.[Description] ) AS ECM_Description
                                  , SR.Referred_ServiceFile_ID
                                  , COALESCE(FA_T.Language_ID,FA_EN.Language_ID) AS ECM_Description_Language_ID
                                  , T.Available_Flag
                                  , COALESCE(FA.Is_Engine_Related, 0) AS Is_Engine_Related
                                  , CASE WHEN UPPER(COALESCE(FA_T.[Description],FA_EN.[Description] ))  LIKE '%TELEMATICS%' THEN 1 ELSE 0 END AS Is_TelematicsFlash_Found
                    
                    FROM @ServiceFiles AS T
                        LEFT JOIN sis.ServiceFile_DisplayTerms as SD ON SD.ServiceFile_ID = T.ServiceFile_ID and SD.Type='AC'
                        LEFT JOIN sis.ServiceFile_DisplayTerms_Translation as ST on SD.ServiceFile_DisplayTerms_ID = ST.ServiceFile_DisplayTerms_ID
                        LEFT JOIN sis.ServiceFile_SearchCriteria AS  SC ON T.ServiceFile_ID = SC.ServiceFile_ID
                                                    AND SC.InfoType_ID = 41
                                                    AND SC.Search_Type = 'SN'
                                                    AND SC.Num_Data = ST.Display_Value
                        LEFT JOIN sis.FlashApplication AS FA ON FA.FlashApplication_ID =  SC.Num_Data
                        LEFT JOIN sis.FlashApplication_Translation AS FA_T ON FA_T.FlashApplication_ID =  FA.FlashApplication_ID
                AND FA_T.Language_ID = @LANGUAGE_ID
                LEFT JOIN sis.FlashApplication_Translation AS FA_EN ON FA_EN.FlashApplication_ID = FA.FlashApplication_ID
                AND FA_EN.Language_ID = @DEFAULT_LANGUAGE_ID
                LEFT JOIN sis.ServiceFile_Reference AS SR ON SR.ServiceFile_ID = T.ServiceFile_ID
        RETURN;
END