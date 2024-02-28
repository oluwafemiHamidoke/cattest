
CREATE   FUNCTION [SISSEARCH].[fn_PRODUCTHIERARCHY](@DATE DATETIME)
RETURNS TABLE
AS
RETURN SELECT 
--
-- 4. Aggregate Family_Code and concatenate already aggregated Subfamily_Code, Sales_Model and Serial_Number_Prefix
-- then prefix and suffix json arrays with the partial values
--
	IESYSTEMCONTROLNUMBER as ID,
	IESYSTEMCONTROLNUMBER,
	'["' + string_agg(string_escape(translate(cast(Family_Code as varchar(max)),
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') + '"]'  as familyCode,
	'["' + string_agg(Subfamily_Code, '","') + '"]'  as familySubFamilyCode,
	'["' + string_agg(Sales_Model, '","') + '"]'  as familySubFamilySalesModel,
	'["' + string_agg(Serial_Number_Prefix, '","') + '"]' as familySubFamilySalesModelSNP,
	MAX(INSERTDATE) INSERTDATE
FROM (
	--
	-- 3. Aggregate Subfamily_Code and concatenate already aggregated Sales_Model and Serial_Number_Prefix
	--
	SELECT IESYSTEMCONTROLNUMBER, Family_Code, 
		-- Compute Subfamily_Code with ancestors 
		string_agg(string_escape(translate(cast(Family_Code +'_'+ Subfamily_Code as varchar(max)),
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') as Subfamily_Code,
	    string_agg(Sales_Model, '","') as Sales_Model,
		string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix,
		MAX(INSERTDATE) INSERTDATE
	FROM (
		--
		-- 2. Aggregate Sales_Model and concatenate already aggregated Serial_Number_Prefix
		--
		SELECT IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, 
			-- Compute Sales_Model with ancestors 
			string_agg(string_escape(translate(cast(Family_Code +'_'+ Subfamily_Code + '_'+ Sales_Model as varchar(max)),
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') as Sales_Model,
			string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix,
			MAX(INSERTDATE) INSERTDATE
		FROM (
			--
			-- 1. Aggregate Serial_Number_Prefixes
			--
			SELECT IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model,
				-- Compute Serial_Number_Prefix with ancestors 
				string_agg(string_escape(translate(cast(concat(Family_Code, '_', Subfamily_Code, '_', Sales_Model, '_', Serial_Number_Prefix) as varchar(max)),
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') as Serial_Number_Prefix,
				MAX(INSERTDATE) INSERTDATE
			FROM [SISSEARCH].[fn_PRODUCTHIERARCHY_ORIGIN](@DATE) AS h
			-- WHERE MEDIANUMBER IN ('APH99961', 'AEXQ1229', 'RENR5232', 'BI000092') OR MEDIANUMBER LIKE 'B%'
			GROUP BY IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model
		) AS x
		GROUP BY IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code
	) AS y
	GROUP BY IESYSTEMCONTROLNUMBER, Family_Code
) AS z
GROUP BY IESYSTEMCONTROLNUMBER