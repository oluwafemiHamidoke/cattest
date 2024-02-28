
--CREATE OR ALTER VIEW SISSEARCH.vw_IEPARTSHISTORY12N as
--select
--	x.part_number AS PARTNUMBER,
--	(
--		SELECT '["'+string_agg(o.RetVal, '","')+'"]' FROM (
--			--
--			--
--			Select DISTINCT --RetSeq = Row_Number() over (Order By (Select null)),
--				RetVal = LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)')))
--			From (
--				Select x = Cast('<x>' + replace((
--					Select string_agg(cast(substring(z.supersessionchain, 0, patindex('%'+x.part_number+'%', z.supersessionchain)-1) as varchar(max)), '|') as [*] For XML Path('')
--			),'|','</x><x>')+'</x>' as xml).query('.')) as A 
--			Cross Apply x.nodes('x') AS B(i)
--			WHERE LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)'))) is not null
--		) o
----		[SISSEARCH].[tvf_StringParse](string_agg(cast(substring(z.supersessionchain, 0, patindex('%'+x.part_number+'%', z.supersessionchain)-1) as varchar(max)), '|'), '|')
--	) as IEPARTHISTORY,
--	(
--		SELECT '["'+string_agg(v.RetVal, '","')+'"]' FROM (
--			Select DISTINCT --RetSeq = Row_Number() over (Order By (Select null)),
--				RetVal = LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)')))
--			From (
--				Select x = Cast('<x>' + replace((
--					Select string_agg(cast(substring(z.supersessionchain, len(x.part_number) + patindex('%'+x.part_number+'%', z.supersessionchain)+1, len(z.supersessionchain)) as varchar(max)),'|') as [*] For XML Path('')
--			),'|','</x><x>')+'</x>' as xml).query('.')) as A 
--			Cross Apply x.nodes('x') AS B(i)
--			WHERE LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)'))) is not null
--		) v
----		[SISSEARCH].[tvf_StringParse](string_agg(cast(substring(z.supersessionchain, len(x.part_number) + patindex('%'+x.part_number+'%', z.supersessionchain)+1, len(z.supersessionchain)) as varchar(max)),'|'), '|')
--	) as IEPARTREPLACEMENT
--from (
--	select part_number, count(supersessionchain_id) as c
--	from sis.supersessionchain_part_relation a , sis.part b
--	where a.part_id=b.part_id
--	group by part_number
--	-- having count(*)=1
--) x,
--(
--	select part_number, supersessionchain_id
--	from sis.Supersessionchain_Part_Relation a, sis.part b
--	where a.part_id=b.part_id
--) y,
--sis.SupersessionChain z
--where x.part_number=y.part_number
--	and y.supersessionchain_id=z.supersessionchain_id
--GROUP BY x.part_number
--GO

CREATE   VIEW SISSEARCH.vw_IEPARTSHISTORY12N as
SELECT
	x.[Part_Number],
	-- string_agg(cast(substring(z.supersessionchain, 0, patindex('%'+x.part_number+'%', z.supersessionchain)-1) as varchar(max)), '|') as historyfull,
	(
		select replace('["'+string_agg(o.value, '","')+'"]', '""', '') from (
			select distinct value
				FROM string_split(string_agg(cast(substring(z.[SupersessionChain], 0, patindex('%'+x.[Part_Number]+'%', z.[SupersessionChain])-1) as varchar(max)), '|'), '|') x
			WHERE x.value is not null
		) o
	) as IEPARTHISTORY,
	-- string_agg(cast(substring(z.supersessionchain, len(x.part_number) + patindex('%'+x.part_number+'%', z.supersessionchain)+1, len(z.supersessionchain)) as varchar(max)), '|') as replacementfull,
	(
		select replace('["'+string_agg(o.value, '","')+'"]', '""', '') from (
			select distinct value
				FROM string_split(string_agg(cast(substring(z.[SupersessionChain], len(x.[Part_Number]) + patindex('%'+x.[Part_Number]+'%', z.[SupersessionChain])+1, len(z.[SupersessionChain])) as varchar(max)), '|'), '|') x
			WHERE x.value is not null
		) o
	) as IEPARTREPLACEMENT
FROM
(
	select [Part_Number], count([SupersessionChain_ID]) as c
	from [sis].[SupersessionChain_Part_Relation] a , [sis].[Part] b
	where a.[Part_ID]=b.[Part_ID]
	group by [Part_Number]
	-- having count(*)=1
) x,
(
	select [Part_Number], [SupersessionChain_ID]
	from [sis].[SupersessionChain_Part_Relation] a, [sis].[Part] b
	where a.[Part_ID]=b.[Part_ID]
) y,
sis.SupersessionChain z
where x.[Part_Number]=y.[Part_Number]
	and y.[SupersessionChain_ID]=z.[SupersessionChain_ID]
GROUP BY x.[Part_Number]