CREATE FUNCTION [SISSEARCH].[fn_compare_source_target_columns] (@col1 nvarchar(max),@col2 nvarchar(max),@check bit)
RETURNS BIT AS
BEGIN
DECLARE @Result BIT;
   IF @check=1
   BEGIN
		 SELECT @Result= CASE WHEN 
		(   NOT (@col1 is NULL and @col2='')
			AND
			(  
	            @col1 <> @col2
		    or (@col1 is null and @col2 is not null)    
			or (@col1 is not null and @col2 is null)
			)
		)
		THEN 
		CAST(1 AS BIT)
		ELSE 
		CAST(0 AS BIT)
		END
	END
	ELSE
   BEGIN
	 SELECT @Result= CASE WHEN 
		    (
			    @col1 <> @col2
			or (@col1 is null and @col2 is not null)
			or (@col1 is not null and @col2 is null)
			)
		THEN 
		CAST(1 AS BIT)
		ELSE 
		CAST(0 AS BIT)
		END
    END
	   RETURN @Result
END
