CREATE PROCEDURE [sis].[SP_GuidedTroubleshooting_PartNumberDescription] (@PARTNUMBERS  NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON
	DROP TABLE IF EXISTS #ResultSet 
	DROP TABLE IF EXISTS #PartNum 

	CREATE TABLE #PartNum
	(
		PartNum	VARCHAR(50)
	);

	insert into #PartNum 
	SELECT value FROM STRING_SPLIT(@PARTNUMBERS,',');

	SELECT 
		LC.IEPARTNAME AS PARTNAME,  LC.[IEPARTNUMBER] AS PARTNUMBER,
		Row_Number() Over (Partition By LC.[IEPARTNUMBER] Order by [DATEUPDATED] DESC) RowRank1
		into #ResultSet
	FROM 
		[SISWEB_OWNER].[LNKMEDIAIEPART] as LC 
		inner join SISWEB_OWNER.LNKIEDATE as LD on (LD.IESYSTEMCONTROLNUMBER=LC.IESYSTEMCONTROLNUMBER and LC.ORGCODE='CAT')
	WHERE 
		LC.[IEPARTNUMBER] in 
		(select PartNum from #PartNum)

	if exists(select 1 from #PartNum where PartNum Not in (select [PARTNUMBER] from #ResultSet))
	BEGIN
		insert into #ResultSet
		SELECT 
			LC.PARTNAME AS PARTNAME,  
			LC.[PARTNUMBER] AS PARTNUMBER,
			Row_Number() Over (Partition By LC.[PARTNUMBER] ORDER BY (SELECT 1)) RowRank2
		FROM 
			[SISWEB_OWNER].[LNKCONSISTLIST] as LC 
			inner join 
			SISWEB_OWNER.LNKIEDATE as LD 
			on (LD.IESYSTEMCONTROLNUMBER=LC.IESYSTEMCONTROLNUMBER and LC.ORGCODE='CAT')
		WHERE 
			LC.[PARTNUMBER] 
			in (
				select PartNum 
					from #PartNum 
						where PartNum Not in 
						(
							select [PARTNUMBER] from #ResultSet
						)
				)
	END			

	if exists(select 1 from #PartNum where PartNum Not in (select [PARTNUMBER] from #ResultSet))
	BEGIN
		insert into #ResultSet
		SELECT 
			LC.RELATEDPARTNAME AS PARTNAME,  
			LC.RELATEDPARTNUMBER AS PARTNUMBER, 
			Row_Number() Over (Partition By LC.RELATEDPARTNUMBER ORDER BY LC.RELATEDPARTNUMBER) RowRank3 
		FROM 
			[SISWEB_OWNER].[LNKRELATEDPARTINFO] as LC 
		WHERE 
			LC.RELATEDPARTNUMBER 
			in (
				select PartNum 
					from #PartNum 
						where PartNum Not in 
						(
							select [PARTNUMBER] from #ResultSet
						)
				)
	END
	
	if exists(select 1 from #PartNum where PartNum Not in (select [PARTNUMBER] from #ResultSet))
	BEGIN
		insert into #ResultSet
		SELECT  
			LC.PARTNUMBERDESCRIPTION AS PARTNAME,
			LC.PARTNUMBER AS PARTNUMBER, 
		Row_Number() Over (Partition By LC.PARTNUMBER ORDER BY LC.PARTNUMBER) RowRank4
		FROM 
			[SISWEB_OWNER].LNKNPRINFO as LC 
		WHERE 
			LC.PARTNUMBER  
			in (
				select PartNum 
					from #PartNum 
						where PartNum Not in 
						(
							select [PARTNUMBER] from #ResultSet
						)
				)	

	END

	select 
		PARTNUMBER, 
		PARTNAME
	FROM 
		#ResultSet 
			WHERE 
			RowRank1=1

	DROP TABLE IF EXISTS #ResultSet 
	DROP TABLE IF EXISTS #PartNum 

END