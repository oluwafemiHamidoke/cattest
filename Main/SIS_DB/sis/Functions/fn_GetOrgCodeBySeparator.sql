CREATE FUNCTION sis.fn_GetOrgCodeBySeparator(@value varchar(60), @ORGCODE_SEPARATOR VARCHAR(1), @DEFAULT_ORGCODE VARCHAR(12))
RETURNS VARCHAR(12)
AS
    BEGIN
		DECLARE @Org_Code VARCHAR(12)

        SET @Org_Code = case
		                        when @value  is null then null
		                        when CHARINDEX(@ORGCODE_SEPARATOR, @value) > 0
		                        then REVERSE(SUBSTRING(REVERSE(@value),0,CHARINDEX(@ORGCODE_SEPARATOR,REVERSE(@value))))
		                        else @DEFAULT_ORGCODE
                        END
        RETURN @Org_Code
    END;
GO