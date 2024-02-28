
CREATE VIEW SISSEARCH.[vw_MediaFamily] AS
SELECT
	Media_ID,
	'["' + string_agg(cast(Family_Code as varchar(max)), '","') + '"]'  as Family_Code,
	'["' + string_agg(Subfamily_Code, '","') + '"]'  as Subfamily_Code,
	'["' + string_agg(Sales_Model, '","') + '"]'  as Sales_Model,
	'["' + string_agg(Serial_Number_Prefix, '","') + '"]' as Serial_Number_Prefix
FROM (
	--
	-- 3. Aggregate Subfamily_Code and concatenate already aggregated Sales_Model and Serial_Number_Prefix
	--
	SELECT Media_ID, Family_Code, 
		-- Compute Subfamily_Code with ancestors 
		string_agg(cast(Family_Code +'_'+ Subfamily_Code as varchar(max)), '","') as Subfamily_Code,
	    string_agg(Sales_Model, '","') as Sales_Model,
		string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix
	FROM (
		--
		-- 2. Aggregate Sales_Model and concatenate already aggregated Serial_Number_Prefix
		--
		SELECT Media_ID, Family_Code, Subfamily_Code, 
			-- Compute Sales_Model with ancestors 
			string_agg(cast(Family_Code +'_'+ Subfamily_Code + '_'+ Sales_Model as varchar(max)), '","') as Sales_Model,
			string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix
		FROM (
			--
			-- 1. Aggregate Serial_Number_Prefixes
			--
			SELECT Media_ID, Family_Code, Subfamily_Code, Sales_Model,
				-- Compute Serial_Number_Prefix with ancestors 
				string_agg(cast(concat(Family_Code, '_', Subfamily_Code, '_', Sales_Model, '_', Serial_Number_Prefix) as varchar(max)), '","') as Serial_Number_Prefix
			FROM SISSEARCH.vw_MediaFamily_Origin AS h
			GROUP BY Media_ID, Family_Code, Subfamily_Code, Sales_Model
		) AS x
		GROUP BY Media_ID, Family_Code, Subfamily_Code
	) AS y
	GROUP BY Media_ID, Family_Code
) AS z
GROUP BY Media_ID
GO