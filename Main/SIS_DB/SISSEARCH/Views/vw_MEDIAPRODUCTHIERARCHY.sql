
CREATE   VIEW [SISSEARCH].[vw_MEDIAPRODUCTHIERARCHY] AS
--
-- 4. Aggregate Family_Code and concatenate already aggregated Subfamily_Code, Sales_Model and Serial_Number_Prefix
-- then prefix and suffix json arrays with the partial values
--
SELECT 
	MEDIANUMBER as ID,
	MEDIANUMBER as BaseEnglishMediaNumber,
	'["' + string_agg(cast(Family_Code as varchar(max)), '","') + '"]'  as familyCode,
	'["' + string_agg(Subfamily_Code, '","') + '"]'  as familySubfamilyCode,
	'["' + string_agg(Sales_Model, '","') + '"]'  as familySubFamilySalesModel,
	'["' + string_agg(Serial_Number_Prefix, '","') + '"]' as familySubFamilySalesModelSNP
FROM (
	--
	-- 3. Aggregate Subfamily_Code and concatenate already aggregated Sales_Model and Serial_Number_Prefix
	--
	SELECT MEDIANUMBER, Family_Code, 
		-- Compute Subfamily_Code with ancestors 
		string_agg(cast(Family_Code +'_'+ Subfamily_Code as varchar(max)), '","') as Subfamily_Code,
	    string_agg(Sales_Model, '","') as Sales_Model,
		string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix
	FROM (
		--
		-- 2. Aggregate Sales_Model and concatenate already aggregated Serial_Number_Prefix
		--
		SELECT MEDIANUMBER, Family_Code, Subfamily_Code, 
			-- Compute Sales_Model with ancestors 
			string_agg(cast(Family_Code +'_'+ Subfamily_Code + '_'+ Sales_Model as varchar(max)), '","') as Sales_Model,
			string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix
		FROM (
			--
			-- 1. Aggregate Serial_Number_Prefixes
			--
			SELECT MEDIANUMBER, Family_Code, Subfamily_Code, Sales_Model,
				-- Compute Serial_Number_Prefix with ancestors 
				string_agg(cast(concat(Family_Code, '_', Subfamily_Code, '_', Sales_Model, '_', Serial_Number_Prefix) as varchar(max)), '","') as Serial_Number_Prefix
			FROM [SISSEARCH].[vw_MEDIAPRODUCT] AS h
			-- WHERE MEDIANUMBER IN ('APH99961', 'AEXQ1229', 'RENR5232', 'BI000092') OR MEDIANUMBER LIKE 'B%'
			GROUP BY MEDIANUMBER, Family_Code, Subfamily_Code, Sales_Model
		) AS x
		GROUP BY MEDIANUMBER, Family_Code, Subfamily_Code
	) AS y
	GROUP BY MEDIANUMBER, Family_Code
) AS z
GROUP BY MEDIANUMBER