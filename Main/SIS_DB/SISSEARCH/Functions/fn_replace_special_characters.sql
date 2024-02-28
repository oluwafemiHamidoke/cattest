CREATE FUNCTION [SISSEARCH].[fn_replace_special_characters] (@column_name nvarchar(500),@null_check bit)
RETURNS nvarchar(500) AS
BEGIN
DECLARE @Result nvarchar(500); 
IF @null_check=1
	SET @Result=replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(@column_name,''),'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/');
ELSE
	SET @Result= replace(replace(replace(replace(replace(replace(replace(replace(replace(@column_name,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/');
RETURN @Result; 
END	