CREATE FUNCTION [sis].[tvf_AsShippedEngine_IESCN] (@Prime_SerialNumber VARCHAR(12) )

    RETURNS @IESystemControlNumber TABLE (IESystemControlNumber VARCHAR(12))
    AS
    BEGIN 
    
        INSERT INTO @IESystemControlNumber
        SELECT DISTINCT mediaseque5_.IESystemControlNumber AS col_0_0_ FROM  (
            SELECT distinct MediaSection_ID 
            FROM sis.CaptivePrime_Serial captivepri1_ 
            INNER JOIN sis.MediaSection sismediase4_ ON (captivepri1_.Media_ID = sismediase4_.Media_ID)
            WHERE captivepri1_.Prime_SerialNumber = @Prime_SerialNumber 
                AND captivepri1_.Attachment_Type = 'EN') AS A
        ,
        (SELECT distinct iepartiepa3_.Related_IEPart_ID 
        FROM sis.CaptivePrime_Serial captivepri1_ 
        INNER JOIN sis.AsShippedEngine asshippede0_ ON 
            (captivepri1_.Captive_SerialNumberPrefix_ID = asshippede0_.SerialNumberPrefix_ID
            AND captivepri1_.Captive_SerialNumberRange_ID = asshippede0_.SerialNumberRange_ID)
        INNER JOIN sis.IEPart iepart2_ ON (iepart2_.Part_ID = asshippede0_.Part_ID)
        INNER JOIN sis.IEPart_IEPart_Relation iepartiepa3_ ON (iepart2_.IEPart_ID = iepartiepa3_.IEPart_ID)
        WHERE captivepri1_.Prime_SerialNumber = @Prime_SerialNumber 
            AND captivepri1_.Attachment_Type = 'EN') AS B
        ,
        sis.MediaSequence mediaseque5_
        WHERE B.Related_IEPart_ID = mediaseque5_.IEPart_ID
            AND mediaseque5_.MediaSection_ID = A.MediaSection_ID

        RETURN

    END