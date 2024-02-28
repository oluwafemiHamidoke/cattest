CREATE FUNCTION sis.fn_GetPartNumberBySeparator(@value varchar(60), @ORGCODE_SEPARATOR VARCHAR(1))
RETURNS VARCHAR(40)
AS
    BEGIN
		DECLARE @Part_Number VARCHAR(40)

        SET @Part_Number = case
		                        when @value  is null then null
		                        when CHARINDEX(@ORGCODE_SEPARATOR, @value) > 0
		                        then SUBSTRING(@value, 1, LEN(@value) - CHARINDEX(@ORGCODE_SEPARATOR,REVERSE(@value)))
		                        else @value
                                END
        RETURN @Part_Number
    END;
GO