
CREATE VIEW SISWEB_OWNER_STAGING.VW_MASREPAIRDESCRIPTIONS
AS SELECT SMCS_ITM_CD, SMCS_ITM_TYPe, smcs_itm_lang, SMCS_ITM_DESC
     FROM (SELECT b.SMCS_ITM_CD, 'C' SMCS_ITM_TYPe, 'E' smcs_itm_lang,
                  b.SMCS_ITM_DESC
             FROM [SISWEB_OWNER_STAGING].[SMCS_CMPNT] a INNER JOIN [SISWEB_OWNER_STAGING].[SMCS_DESC] b
                  ON a.SMCS_ITM_TYP = b.SMCS_ITM_TYP
                AND a.SMCS_CMPNT_CD = b.SMCS_ITM_CD
            WHERE SMCS_DESC_TYP IN ('B', 'L')
              AND CD_ASGN_IND = 'Y'
              AND WHERE_PUB_CD = 'P'
           UNION ALL
           SELECT b.SMCS_ITM_CD, 'J' SMCS_ITM_TYPe, 'E' smcs_itm_lang,
                  b.SMCS_ITM_DESC
             FROM [SISWEB_OWNER_STAGING].[SMCS_JOB] a INNER JOIN [SISWEB_OWNER_STAGING].[SMCS_DESC] b
                  ON a.SMCS_ITM_TYP = b.SMCS_ITM_TYP
                AND a.SMCS_JOB_CD = b.SMCS_ITM_CD
            WHERE SMCS_DESC_TYP IN ('B', 'L')
              AND CD_ASGN_IND = 'Y'
              AND WHERE_PUB_CD = 'P'
           UNION ALL
           SELECT b.SMCS_ITM_CD, 'M' SMCS_ITM_TYPe, 'E' smcs_itm_lang,
                  b.SMCS_ITM_DESC 
             FROM [SISWEB_OWNER_STAGING].[SMCS_MDFY] a INNER JOIN [SISWEB_OWNER_STAGING].[SMCS_DESC] b
                  ON a.SMCS_ITM_TYP = b.SMCS_ITM_TYP
                AND a.SMCS_MDFY_CD = b.SMCS_ITM_CD
            WHERE  SMCS_DESC_TYP IN ('B', 'L')
              AND CD_ASGN_IND = 'Y'
              AND WHERE_PUB_CD = 'P') x;
