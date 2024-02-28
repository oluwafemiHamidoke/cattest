CREATE   FUNCTION [SISSEARCH].[tvf_StringParse](@String varchar(max),@Delimiter varchar(10))
Returns Table 
As
Return (  
    Select DISTINCT --RetSeq = Row_Number() over (Order By (Select null)),
          RetVal = LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)')))
    From (
		Select x = Cast('<x>' + replace((
			Select replace(@String ,@Delimiter, '|') as [*] For XML Path('')
		),'|','</x><x>')+'</x>' as xml).query('.')
	) as A 
    Cross Apply x.nodes('x') AS B(i)
	WHERE LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)'))) is not null
)