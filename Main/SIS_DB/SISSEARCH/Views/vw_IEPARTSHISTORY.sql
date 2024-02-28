CREATE VIEW SISSEARCH.vw_IEPARTSHISTORY
as
SELECT
	x.Part_Number, x.Org_Code,
	(
		select '["'+string_agg(grp.value, '","')+'"]'
		FROM (
				 select concat(x.Part_Number,':',addpn.value) as value
				 FROM
					 (
					 select distinct value
					 from string_split(string_agg(cast(
					 substring(z.SupersessionChain, 0,
					 patindex('%|'+replace(x.Part_Number, '[', '[[]')+'%', z.SupersessionChain)) as varchar(max)), '|'), '|')
					 WHERE value is not null and value!=''
					 )addpn
			 )grp
	) as IEPARTHISTORY,
	(
		select '["'+string_agg(value, '","')+'"]'
		FROM (
				 select concat(x.Part_Number,':',addpnr.value) as value
				 FROM
					 (
					 select distinct value
					 FROM string_split(string_agg(cast(+substring(z.SupersessionChain, len(x.Part_Number) + patindex('%|'+x.Part_Number+'%', z.SupersessionChain)+2,
					 len(z.SupersessionChain)) as varchar(max)), '|'), '|') mr
					 WHERE value is not null AND value!=''
					 )addpnr
			 ) grpr
	) as IEPARTREPLACEMENT
FROM
	(
		select b.Part_Number, b.Org_Code, count(a.SupersessionChain_ID) as c
		from sis.SupersessionChain_Part_Relation as a , sis.Part as b
		where a.Part_ID=b.Part_ID
		group by b.Part_Number, b.Org_Code
		-- having count(*)=1
	) x,
	(
		select b.Part_Number, b.Org_Code, a.SupersessionChain_ID
		from sis.SupersessionChain_Part_Relation as a, sis.Part as b
		where a.Part_ID=b.Part_ID
	) y,
	(
		select
			t.SupersessionChain_ID as SupersessionChain_ID,
			string_agg(SISWEB_OWNER_STAGING._getPartNumberBySeparator(value,SISWEB_OWNER_STAGING._getDefaultORGCODESeparator()), '|') as SupersessionChain
		from sis.SupersessionChain t
			CROSS APPLY string_split(t.SupersessionChain, '|') value
		group by t.SupersessionChain_ID
	) z,
	sis.Part p
where x.Part_Number=y.Part_Number and p.Part_Number=x.Part_Number and x.Org_Code=y.Org_Code and p.Org_Code=x.Org_Code
  and y.SupersessionChain_ID=z.SupersessionChain_ID
GROUP BY x.Part_Number, x.Org_Code
	GO
