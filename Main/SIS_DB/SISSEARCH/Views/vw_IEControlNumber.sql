
CREATE    VIEW [SISSEARCH].vw_IEControlNumber AS
select e.IE_ID, '["'+tr.IEControlNumber+'"]' as ControlNumber
	from sis.IE e
	 inner join sis.IE_Translation tr on e.IE_ID=tr.IE_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Language_Code='en'