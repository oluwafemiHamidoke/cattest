CREATE VIEW [SISSEARCH].[vw_CONSISTPARTSHISTORY_ORIGIN]
AS
SELECT b.Part_Number as Part_Number, b.Org_Code as Org_Code,
	   (
		   select string_agg(o.value, '","')
		   from (
					select distinct b.Part_Number +':'+value as value
					FROM string_split(string_agg(cast(substring(z.SupersessionChain, 0,
						patindex('%|'+replace(b.Part_Number, '[', '[[]')+'%', z.SupersessionChain)) as varchar(max)), '|'), '|') x
					WHERE x.value is not null AND x.value!=''
				) o
	   ) as CONSISTPARTHISTORY,
	   (
		   select string_agg(o.value, '","')
		   from (
					select distinct b.Part_Number+':'+value as value
					FROM string_split(string_agg(cast(substring(z.SupersessionChain, len(b.Part_Number) + patindex('%|'+b.Part_Number+'%', z.SupersessionChain)+2, len(z.SupersessionChain)) as varchar(max)), '|'), '|') x
					WHERE x.value is not null AND x.value!=''
				) o
	   ) as CONSISTPARTREPLACEMENT
FROM (
		select b.Part_Number as Part_Number, b.Org_Code as Org_Code
		from sis.SupersessionChain_Part_Relation as a, sis.Part as b
		where a.Part_ID=b.Part_ID
		group by b.Part_Number, b.Org_Code
		having count(*)=1

		Union 

		select b.Part_Number as Part_Number, b.Org_Code as Org_Code
		from sis.SupersessionChain_Part_Relation as a, sis.Part as b,[sis_stage].[Supersession_Part_Relation] c
		where a.Part_ID=b.Part_ID and a.Part_ID=c.Part_ID and isExpandedMiningProduct = 1
		group by b.Part_Number, b.Org_Code
		having count(*)>1
	 ) b,
	 (
		 SELECT b.Part_Number as Part_Number, b.Org_Code as Org_Code, a.SupersessionChain_ID as SupersessionChain_ID
		 FROM sis.SupersessionChain_Part_Relation as a,
			  sis.Part as b
		 WHERE a.Part_ID=b.Part_ID
	 ) y,
	 (
		 select
			 t.SupersessionChain_ID as SupersessionChain_ID,
			 string_agg(SISWEB_OWNER_STAGING._getPartNumberBySeparator(value,SISWEB_OWNER_STAGING._getDefaultORGCODESeparator()), '|') as SupersessionChain
		 from sis.SupersessionChain t
			 CROSS APPLY string_split(t.SupersessionChain, '|') value
		 group by t.SupersessionChain_ID
	 ) z
WHERE b.Part_Number=y.Part_Number and b.Org_Code=y.Org_Code
  AND y.SupersessionChain_ID=z.SupersessionChain_ID
  --AND b.Part_Number='1799782'
GROUP BY b.Part_Number, b.Org_Code
	GO
