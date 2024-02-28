CREATE VIEW [SISSEARCH].[vw_IEPARTSHISTORY_RAW]
	AS SELECT
		x.Part_Number,
		-- string_agg(cast(substring(z.supersessionchain, 0, patindex('%'+x.part_number+'%', z.supersessionchain)-1) as varchar(max)), '|') as historyfull,
		(
			select string_agg(o.value, '|') from (
				select distinct value
					FROM string_split(string_agg(cast(substring(z.SupersessionChain, 0, patindex('%'+x.Part_Number+'%', z.SupersessionChain)-1) as varchar(max)), '|'), '|') x
				WHERE x.value is not null
			) o
		) as IEPARTHISTORY,
		-- string_agg(cast(substring(z.supersessionchain, len(x.part_number) + patindex('%'+x.part_number+'%', z.supersessionchain)+1, len(z.supersessionchain)) as varchar(max)), '|') as replacementfull,
		(
			select string_agg(o.value, '|') from (
				select distinct value
					FROM string_split(string_agg(cast(substring(z.SupersessionChain, len(x.Part_Number) + patindex('%'+x.Part_Number+'%', z.SupersessionChain)+1, len(z.SupersessionChain)) as varchar(max)), '|'), '|') x
				WHERE x.value is not null
			) o
		) as IEPARTREPLACEMENT

		--cast(substring(z.SupersessionChain, 0, patindex('%'+x.Part_Number+'%', z.SupersessionChain)-1) as varchar(max)) as IEPARTHISTORY,
		--cast(substring(z.SupersessionChain, len(x.Part_Number) + patindex('%'+x.Part_Number+'%', z.SupersessionChain)+1, len(z.SupersessionChain)) as varchar(max)) as IEPARTREPLACEMENT
	FROM
	(
		select Part_Number, count(SupersessionChain_ID) as c
		from sis.SupersessionChain_Part_Relation a , sis.Part b
		where a.Part_ID=b.Part_ID
		group by Part_Number
	) x,
	(
		select Part_Number, SupersessionChain_ID
		from sis.SupersessionChain_Part_Relation a, sis.Part b
		where a.Part_ID=b.Part_ID
	) y,
	sis.SupersessionChain z
	where x.Part_Number=y.Part_Number
		and y.SupersessionChain_ID=z.SupersessionChain_ID
	GROUP BY x.Part_Number