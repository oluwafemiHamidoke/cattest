-- =============================================
-- Author:      Krishna Rudraraju
-- Create Date: 20230927
-- Description: Convert sis2go bundle query to stored procedure to improve performance Story #31281 
-- =============================================
CREATE PROCEDURE [sis].[SP_Part_PartName_Translation] (@Media_Number VARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON
	DROP TABLE IF EXISTS #t1
	DROP TABLE IF EXISTS #t2
	DROP TABLE IF EXISTS #t3
	DROP TABLE IF EXISTS #t4
	DROP TABLE IF EXISTS #t5
	DROP TABLE IF EXISTS #t6
	DROP TABLE IF EXISTS #t7
	DROP TABLE IF EXISTS #t8
	DROP TABLE IF EXISTS #t9
	DROP TABLE IF EXISTS #t10
	DROP TABLE IF EXISTS #t11
	DROP TABLE IF EXISTS #t12
	DROP TABLE IF EXISTS #t13
	DROP TABLE IF EXISTS #t14
	DROP TABLE IF EXISTS #t15
	DROP TABLE IF EXISTS #t16
	DROP TABLE IF EXISTS #t17
	DROP TABLE IF EXISTS #t18
	DROP TABLE IF EXISTS #t19
	DROP TABLE IF EXISTS #t20
	DROP TABLE IF EXISTS #t21
	DROP TABLE IF EXISTS #t22
	DROP TABLE IF EXISTS #t23
	DROP TABLE IF EXISTS #t24
	DROP TABLE IF EXISTS #t25
	DROP TABLE IF EXISTS #t26
	DROP TABLE IF EXISTS #t27
	DROP TABLE IF EXISTS #t28
	DROP TABLE IF EXISTS #t29
	DROP TABLE IF EXISTS #t30
	DROP TABLE IF EXISTS #t31
	DROP TABLE IF EXISTS #t32
	DROP TABLE IF EXISTS #t33
	DROP TABLE IF EXISTS #t34
	DROP TABLE IF EXISTS #t35
	DROP TABLE IF EXISTS #t36
	
	SELECT DISTINCT mp.MEDIANUMBER,ts.PARTNAME,ts.TRANSLATEDPARTNAME,ts.LANGUAGEINDICATOR
	INTO #t1
	FROM SISWEB_OWNER.LNKMEDIAIEPART mp 
	INNER JOIN SISWEB_OWNER.LNKTRANSLATEDSPN ts
	ON ts.PARTNAME = mp.IEPARTNAME
	WHERE mp.MEDIANUMBER=@Media_Number
	
	SELECT DISTINCT t1.MEDIANUMBER,t1.PARTNAME,t1.TRANSLATEDPARTNAME,t1.LANGUAGEINDICATOR,l.Language_Code
	INTO #t2
	FROM #t1 t1 JOIN sis.Language l
	ON t1.LANGUAGEINDICATOR = l.Legacy_Language_Indicator AND l.Default_Language = '1'
	
	SELECT DISTINCT mp.MEDIANUMBER,cl.PARTNAME
	INTO #t3
	FROM SISWEB_OWNER.LNKMEDIAIEPART mp 
	INNER JOIN SISWEB_OWNER.LNKCONSISTLIST cl
	ON cl.IESYSTEMCONTROLNUMBER = mp.IESYSTEMCONTROLNUMBER
	WHERE mp.MEDIANUMBER = @Media_Number
	
	SELECT DISTINCT t3.MEDIANUMBER,t3.PARTNAME,ts.TRANSLATEDPARTNAME,ts.LANGUAGEINDICATOR
	INTO #t4
	FROM #t3 t3
	INNER JOIN SISWEB_OWNER.LNKTRANSLATEDSPN ts
	ON ts.PARTNAME = t3.PARTNAME
	
	CREATE NONCLUSTERED INDEX [IX_NCL_t4_LANGUAGEINDICATOR]
	ON [dbo].[#t4] ([LANGUAGEINDICATOR])
	INCLUDE ([MEDIANUMBER],[PARTNAME],[TRANSLATEDPARTNAME])
	
	SELECT DISTINCT t4.MEDIANUMBER,t4.PARTNAME,t4.TRANSLATEDPARTNAME,t4.LANGUAGEINDICATOR,l.Language_Code
	INTO #t5
	FROM #t4 t4 
	INNER JOIN sis.Language l
	ON t4.LANGUAGEINDICATOR = l.Legacy_Language_Indicator AND l.Default_Language = '1'
	
	SELECT DISTINCT IESYSTEMCONTROLNUMBER,SNP,MEDIANUMBER
	INTO #t6
	FROM SISWEB_OWNER.lnkpartsiesnp
	WHERE MEDIANUMBER = @Media_Number
	
	SELECT DISTINCT lm.IESYSTEMCONTROLNUMBER, lm.IEPARTNUMBER,t6.SNP
	INTO #t7
	FROM 
	SISWEB_OWNER.lnkmediaiepart lm
	JOIN #t6 t6
	ON lm.IESYSTEMCONTROLNUMBER=t6.IESYSTEMCONTROLNUMBER
	
	
	SELECT DISTINCT lp.CLASSICPARTINDICATOR,t7.IESYSTEMCONTROLNUMBER, t7.IEPARTNUMBER
	INTO #t8
	FROM SISWEB_OWNER.LNKPRODUCT lp
	JOIN #t7 t7
	ON lp.SNP=t7.SNP
	
	SELECT DISTINCT lrp.RELATEDPARTNAME,t8.IESYSTEMCONTROLNUMBER
	INTO #t9
	FROM SISWEB_OWNER.LNKRELATEDPARTINFO lrp 
	JOIN #t8 t8 
	ON lrp.PARTNUMBER=t8.IEPARTNUMBER
	WHERE lrp.TYPEINDICATOR <> 'K'
		AND lrp.TYPEINDICATOR <> 'E'
		AND lrp.TYPEINDICATOR <> CASE WHEN t8.CLASSICPARTINDICATOR = 'N' THEN 'CL' ELSE '' END
	
	SELECT DISTINCT  lip.PSID,t9.RELATEDPARTNAME
	INTO #t10
	FROM SISWEB_OWNER.lnkiepsid lip 
	JOIN #t9 t9
	ON lip.IESYSTEMCONTROLNUMBER=t9.IESYSTEMCONTROLNUMBER
	
	
	SELECT DISTINCT mp1.PARENTPRODUCTSTRUCTUREID,mp1.LANGUAGEINDICATOR,t10.RELATEDPARTNAME
	INTO #t11
	FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE mp1
	JOIN #t10 t10 
	ON mp1.PRODUCTSTRUCTUREID=t10.PSID
	
	
	SELECT DISTINCT mp2.LANGUAGEINDICATOR,t11.RELATEDPARTNAME
	INTO #t12
	FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE mp2
	JOIN #t11 t11
	ON mp2.PRODUCTSTRUCTUREID=t11.PARENTPRODUCTSTRUCTUREID
	
	SELECT DISTINCT lts.TRANSLATEDPARTNAME,lts.LANGUAGEINDICATOR,lts.PARTNAME,t12.RELATEDPARTNAME
	INTO #t13
	FROM #t12 t12
	LEFT OUTER JOIN SISWEB_OWNER.LNKTRANSLATEDSPN lts ON 
	(lts.PARTNAME=t12.RELATEDPARTNAME
		AND lts.LANGUAGEINDICATOR=t12.LANGUAGEINDICATOR
		AND lts.LANGUAGEINDICATOR=t12.LANGUAGEINDICATOR
		AND lts.PARTNAME IS NOT NULL)
	
	SELECT DISTINCT t13.TRANSLATEDPARTNAME,t13.PARTNAME,t13.RELATEDPARTNAME,L.Language_Code
	INTO #t14
	FROM #t13 t13
	INNER JOIN sis.Language L 
	ON L.Legacy_Language_Indicator = t13.LANGUAGEINDICATOR  AND L.Default_Language ='1'
	
	
	SELECT DISTINCT	IESYSTEMCONTROLNUMBER,SNP,MEDIANUMBER
	INTO #t15
	FROM SISWEB_OWNER.lnkpartsiesnp
	WHERE MEDIANUMBER=@Media_Number
	
	SELECT DISTINCT lm.IESYSTEMCONTROLNUMBER, lm.BASEENGCONTROLNO,t15.SNP ,t15.MEDIANUMBER
	INTO #t16
	FROM 
	SISWEB_OWNER.lnkmediaiepart lm
	JOIN #t15 t15
	ON lm.IESYSTEMCONTROLNUMBER=t15.IESYSTEMCONTROLNUMBER
	
	SELECT DISTINCT lp.CLASSICPARTINDICATOR,t16.IESYSTEMCONTROLNUMBER,t16.BASEENGCONTROLNO,t16.MEDIANUMBER
	INTO #t17
	FROM SISWEB_OWNER.LNKPRODUCT lp
	JOIN #t16 t16
	ON lp.SNP=t16.SNP

	
	SELECT DISTINCT m.Source, t17.CLASSICPARTINDICATOR,t17.IESYSTEMCONTROLNUMBER,t17.BASEENGCONTROLNO
	INTO #t18
	FROM sis.Media m
	JOIN #t17 t17
	ON m.Media_Number=t17.MEDIANUMBER
	
	
	SELECT DISTINCT lc.PARTNUMBER,t18.CLASSICPARTINDICATOR,t18.IESYSTEMCONTROLNUMBER
	INTO #t19
	FROM #t18 t18 
	INNER JOIN SISWEB_OWNER.lnkconsistlist lc
	ON (lc.IESYSTEMCONTROLNUMBER=CASE WHEN t18.Source='C'
								      THEN t18.BASEENGCONTROLNO 
									  ELSE t18.IESYSTEMCONTROLNUMBER 
									  END)
	
	
	
	SELECT DISTINCT lrp.RELATEDPARTNAME,t19.IESYSTEMCONTROLNUMBER
	INTO #t20
	FROM SISWEB_OWNER.LNKRELATEDPARTINFO lrp
	JOIN #t19 t19
	ON (lrp.PARTNUMBER=t19.PARTNUMBER)
	WHERE  lrp.TYPEINDICATOR <> 'K'
		AND lrp.TYPEINDICATOR <> 'E'
		AND lrp.TYPEINDICATOR <> CASE WHEN t19.CLASSICPARTINDICATOR = 'N' 
									  THEN 'CL' 
									  ELSE '' 
									  END
	
		
	SELECT DISTINCT  lip.PSID,t20.RELATEDPARTNAME
	INTO #t21
	FROM SISWEB_OWNER.lnkiepsid lip 
	JOIN #t20 t20
	ON lip.IESYSTEMCONTROLNUMBER=t20.IESYSTEMCONTROLNUMBER
	
	SELECT DISTINCT  mp1.PARENTPRODUCTSTRUCTUREID,mp1.LANGUAGEINDICATOR,t21.RELATEDPARTNAME
	INTO #t22 
	FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE mp1
	JOIN #t21 t21 
	ON mp1.PRODUCTSTRUCTUREID=t21.PSID
	
	
	SELECT DISTINCT mp2.LANGUAGEINDICATOR,t22.RELATEDPARTNAME
	INTO #t23
	FROM SISWEB_OWNER.MASPRODUCTSTRUCTURE mp2
	JOIN #t22 t22
	ON mp2.PRODUCTSTRUCTUREID=t22.PARENTPRODUCTSTRUCTUREID
	
	SELECT DISTINCT lts.PARTNAME,lts.TRANSLATEDPARTNAME,lts.LANGUAGEINDICATOR,t23.RELATEDPARTNAME
	INTO #t24 
	FROM #t23 t23
	LEFT OUTER JOIN SISWEB_OWNER.LNKTRANSLATEDSPN lts 
	ON t23.RELATEDPARTNAME=lts.PARTNAME
		AND t23.LANGUAGEINDICATOR=lts.LANGUAGEINDICATOR
	
		
	SELECT DISTINCT t24.PARTNAME,t24.TRANSLATEDPARTNAME,t24.RELATEDPARTNAME,L.Language_Code
	INTO #t25
	FROM 
	#t24 t24 
	INNER JOIN  sis.Language L 
	ON L.Legacy_Language_Indicator = t24.LANGUAGEINDICATOR AND L.Default_Language ='1'
		
	/*** KITS ****/

	SELECT DISTINCT p.Part_ID,t7.IESYSTEMCONTROLNUMBER,t7.IEPARTNUMBER
	INTO #t26
	FROM sis.Part p
	JOIN #t7 t7
	ON (p.Part_Number=t7.IEPARTNUMBER)	
	

	SELECT DISTINCT kitparent.Kit_ID, t26.IESYSTEMCONTROLNUMBER, t26.IEPARTNUMBER
	INTO #t27
	FROM sis.Kit_ParentPart_Relation kitparent
	JOIN #t26 t26
	ON (kitparent.ParentPart_ID = t26.Part_ID)

	SELECT DISTINCT kit.Number as RELATEDPARTNUMBER, kit.Name as RELATEDPARTNAME, t27.IEPARTNUMBER, 
	kit.Part_Type as TYPEINDICATOR, kit.Name as partName,t27.IESYSTEMCONTROLNUMBER, kit.Kit_ID
	INTO  #t28
	FROM sis.Kit kit
	JOIN #t27 t27
	ON (kit.Kit_ID = t27.Kit_ID) where kit.Long_Description is not NULL


	SELECT RELATEDPARTNUMBER, RELATEDPARTNAME, IEPARTNUMBER, TYPEINDICATOR, PARTNAME, MP1.IESYSTEMCONTROLNUMBER, PSID,Kit_ID
	INTO #T29
	FROM #t28 T28
	JOIN  SISWEB_OWNER.lnkiepsid mp1 ON MP1.IESYSTEMCONTROLNUMBER=T28.IESYSTEMCONTROLNUMBER

	SELECT DISTINCT RELATEDPARTNUMBER, RELATEDPARTNAME, IEPARTNUMBER, TYPEINDICATOR, PARTNAME, IESYSTEMCONTROLNUMBER, PARENTPRODUCTSTRUCTUREID,Kit_ID
	INTO #T30
	FROM #t29 T29
	JOIN  SISWEB_OWNER.MASPRODUCTSTRUCTURE mp1 ON MP1.PRODUCTSTRUCTUREID=T29.PSID
	
	SELECT DISTINCT RELATEDPARTNUMBER, RELATEDPARTNAME, IEPARTNUMBER, TYPEINDICATOR, PARTNAME, IESYSTEMCONTROLNUMBER, Kit_ID
	INTO #T31
	FROM #t30 T30
	JOIN  SISWEB_OWNER.MASPRODUCTSTRUCTURE mp1 ON MP1.PRODUCTSTRUCTUREID=T30.PARENTPRODUCTSTRUCTUREID

	
	SELECT DISTINCT t31.PARTNAME, isnull(lts.TRANSLATEDPARTNAME, t31.partName) TRANSLATEDPARTNAME,lts.LANGUAGEINDICATOR,Kit_ID
	INTO #T32
	from #t31 t31
	LEFT OUTER JOIN SISWEB_OWNER.LNKTRANSLATEDSPN lts 
	ON t31.PARTNAME=lts.PARTNAME

	
	select DISTINCT PARTNAME, TRANSLATEDPARTNAME, Case when  L.Language_Code is NULL THEN 'en' ELSE  L.Language_Code end as language, Kit_ID,
	T32.LANGUAGEINDICATOR
	INTO  #T33
	from #T32 T32
	left JOIN  sis.Language L ON L.Legacy_Language_Indicator = T32.LANGUAGEINDICATOR AND L.Default_Language ='1' 
		
	/*** KITS MEDIA ****/
	
	select distinct IESYSTEMCONTROLNUMBER 
	into #T34
	from  SISWEB_OWNER.lnkpartsiesnp partsiesnp where partsiesnp.MEDIANUMBER= @Media_Number

	select distinct  
	kit.Name as partName, systemimpl.LANGUAGEINDICATOR LANGUAGEINDICATOR1, systemimp2.LANGUAGEINDICATOR LANGUAGEINDICATOR2
	,lnkmediaie.IEPARTNAME IEPARTNAME
	into  #T35
	from #T34 T34
	inner join SISWEB_OWNER.lnkmediaiepart lnkmediaie on lnkmediaie.IESYSTEMCONTROLNUMBER=T34.IESYSTEMCONTROLNUMBER
	inner join sis.Media media on media.Media_Number=lnkmediaie.MEDIANUMBER
	inner join SISWEB_OWNER.lnkconsistlist lnkconsist on lnkconsist.IESYSTEMCONTROLNUMBER=case when media.Source='C'
	then lnkmediaie.BASEENGCONTROLNO else lnkmediaie.IESYSTEMCONTROLNUMBER end
	inner join sis.Part part on part.Part_Number = lnkconsist.PARTNUMBER
	inner join sis.Kit_ParentPart_Relation kitparentp on kitparentp.ParentPart_ID = part.Part_ID
	inner join sis.Kit kit on kit.Kit_ID = kitparentp.Kit_ID and kit.Long_Description is not NULL
	inner join SISWEB_OWNER.lnkiepsid lnkiepsid on lnkiepsid.IESYSTEMCONTROLNUMBER=T34.IESYSTEMCONTROLNUMBER
	inner join SISWEB_OWNER.MASPRODUCTSTRUCTURE systemimpl on systemimpl.PRODUCTSTRUCTUREID=lnkiepsid.PSID
	inner join SISWEB_OWNER.MASPRODUCTSTRUCTURE systemimp2 on systemimp2.PRODUCTSTRUCTUREID=systemimpl.PARENTPRODUCTSTRUCTUREID


	select distinct T35.partName,IsNull (lnktransla9.TRANSLATEDPARTNAME,  T35.partName) as TRANSLATEDPARTNAME,
	Case when  L.Language_Code is NULL THEN 'en' ELSE  L.Language_Code end as language
	into #T36
	from #T35 T35
	left  join SISWEB_OWNER.LNKTRANSLATEDSPN lnktransla8 on (lnktransla8.PARTNAME=T35.IEPARTNAME and lnktransla8.LANGUAGEINDICATOR=T35.LANGUAGEINDICATOR1 
	and lnktransla8.LANGUAGEINDICATOR=T35.LANGUAGEINDICATOR2)
	left  join SISWEB_OWNER.LNKTRANSLATEDSPN lnktransla9 on (lnktransla9.PARTNAME=T35.partName )
	left  join sis.Language L on L.Legacy_Language_Indicator = lnktransla9.LANGUAGEINDICATOR and L.Default_Language ='1'
		

	
	SELECT DISTINCT PARTNAME as partName,IsNull(TRANSLATEDPARTNAME,PARTNAME) as translatedPartName,Language_Code as language
	FROM #t2
	union
	SELECT DISTINCT	PARTNAME as partName,IsNull(TRANSLATEDPARTNAME,PARTNAME) as translatedPartName,Language_Code as language
	FROM #t5
	union
	SELECT DISTINCT	IsNull (PARTNAME,RELATEDPARTNAME) as partName,IsNull(TRANSLATEDPARTNAME,RELATEDPARTNAME) as TRANSLATEDPARTNAME, CASE WHEN  Language_Code is NULL THEN 'en' ELSE  Language_Code END as language
	FROM #t14
	union
	SELECT DISTINCT IsNull (PARTNAME,RELATEDPARTNAME) as partName,IsNull(TRANSLATEDPARTNAME,RELATEDPARTNAME) as TRANSLATEDPARTNAME, CASE WHEN  Language_Code is NULL THEN 'en' ELSE  Language_Code END as language
	FROM #t25 
	union
	SELECT DISTINCT PARTNAME as partName,IsNull(TRANSLATEDPARTNAME,PARTNAME) as translatedPartName,language as language
	FROM #T33
	union
	SELECT DISTINCT PARTNAME as partName,IsNull(TRANSLATEDPARTNAME,PARTNAME) as translatedPartName,language as language
	FROM #T36
END
