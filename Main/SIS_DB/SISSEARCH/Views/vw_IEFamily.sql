CREATE VIEW SISSEARCH.vw_IEFamily AS
SELECT 
	z.IE_ID,
	'["' + string_agg(cast(z.Family_Code as varchar(max)), '","') + '"]'  as Family_Code,
	'["' + string_agg(z.Subfamily_Code, '","') + '"]'  as Subfamily_Code,
	'["' + string_agg(z.Sales_Model, '","') + '"]'  as Sales_Model,
	'["' + string_agg(z.Serial_Number_Prefix, '","') + '"]' as Serial_Number_Prefix
FROM (
	--
	-- 3. Aggregate Subfamily_Code and concatenate already aggregated Sales_Model and Serial_Number_Prefix
	--
	SELECT IE_ID, Family_Code, 
		-- Compute Subfamily_Code with ancestors 
		string_agg(cast(Family_Code +'_'+ Subfamily_Code as varchar(max)), '","') as Subfamily_Code,
	    string_agg(Sales_Model, '","') as Sales_Model,
		string_agg(Serial_Number_Prefix, '","') as Serial_Number_Prefix
	FROM (
		--
		-- 2. Aggregate Sales_Model and concatenate already aggregated Serial_Number_Prefix
		--
		SELECT IE_ID, Family_Code, Subfamily_Code, 
			-- Compute Sales_Model with ancestors 
			string_agg(cast(x.Family_Code +'_'+ x.Subfamily_Code + '_'+ x.Sales_Model as varchar(max)), '","') as Sales_Model,
			string_agg(x.Serial_Number_Prefix, '","') as Serial_Number_Prefix
		FROM (
			--
			-- 1. Aggregate Serial_Number_Prefixes
			--
			SELECT IE_ID, Family_Code, Subfamily_Code, Sales_Model,
				-- Compute Serial_Number_Prefix with ancestors 
				string_agg(cast(concat(Family_Code, '_', Subfamily_Code, '_', Sales_Model, '_', Serial_Number_Prefix) as varchar(max)), '","') as Serial_Number_Prefix
			FROM SISSEARCH.vw_IEFamily_Origin
			GROUP BY IE_ID, Family_Code, Subfamily_Code, Sales_Model
		) AS x
		GROUP BY x.IE_ID, x.Family_Code, x.Subfamily_Code
	) AS y
	GROUP BY y.IE_ID, y.Family_Code
) AS z
GROUP BY IE_ID

GO

