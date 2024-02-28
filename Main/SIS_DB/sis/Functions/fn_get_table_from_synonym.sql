   CREATE FUNCTION [sis].[fn_get_table_from_synonym] ( @schema_name  varchar(500),@synonym_name varchar(500))
   RETURNS   varchar(500) AS
   BEGIN
   DECLARE @CurrentSchemaQualifiedTableName varchar(500);
   SELECT @CurrentSchemaQualifiedTableName =
    ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2)))
   + '.'+
   ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
   from sys.synonyms 
   Where Schema_id = schema_id(@schema_name)
   And [Name] = @synonym_name
   RETURN @CurrentSchemaQualifiedTableName
   END
GO