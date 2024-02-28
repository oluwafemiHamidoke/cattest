-- =============================================
-- Author:      Rishabh Khatreja
-- Create Date: 20180926
-- Modify Date: 20190606 - Davide, changed Language_Details tables
-- Description: Full load [sis_stage].Language_Details
--Exec [sis_stage].Language_Details_Load
-- =============================================
CREATE PROCEDURE [sis_stage].[Language_Details_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--Load
Insert into [sis_stage].[Language_Details]
([Language], [Language_Code], [Language_Tag],[Legacy_Language_Indicator],[Default_Language], [LastModifiedDate], [Lang])
Values--http://www.oracle.com/technetwork/java/javase/java8locales-2095355.html
    ('Afrikaans (af)','af','af-ZA','9',1,'1900-01-01','Afrikaans (af)'),
    ('Albanian (sq)','sq','sq-AL','E',0,'1900-01-01','Albanian (sq)'),
    ('Arabic (ar)','ar','ar-DZ','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-BH','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-EG','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-IQ','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-JO','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-KW','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-LB','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-LY','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-MA','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-OM','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-QA','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-SA','A',1,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-SD','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-SY','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-TN','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-AE','E',0,'1900-01-01','Arabic (ar)'),
    ('Arabic (ar)','ar','ar-YE','E',0,'1900-01-01','Arabic (ar)'),
    ('Armenian (hy)','hy','hy-AM','9Y',1,'1900-01-01','Armenian (hy)'),
    ('Belarusian (be)','be','be-BY','E',0,'1900-01-01','Belarusian (be)'),
    ('Bosnian (bs)','bs','bs-BA','9H',1,'1900-01-01','Bosnian (bs)'),
    ('Bulgarian (bg)','bg','bg-BG','E',0,'1900-01-01','Bulgarian (bg)'),
    ('Catalan (ca)','ca','ca-ES','E',0,'1900-01-01','Catalan (ca)'),
    ('Chinese (zh)','zh','zh-CN','C',1,'1900-01-01','Chinese (zh)'),
    ('Chinese (zh)','zh','zh-SG','C',0,'1900-01-01','Chinese (zh)'),
    ('Chinese (zh)','zh','zh-HK','C',0,'1900-01-01','Chinese (zh)'),
    ('Chinese (zh)','zh','zh-TW','C',0,'1900-01-01','Chinese (zh)'),
    ('Croatian (hr)','hr','hr-HR','E',0,'1900-01-01','Croatian (hr)'),
    ('Czech (cs)','cs','cs-CZ','E',0,'1900-01-01','Czech (cs)'),
    ('Danish (da)','da','da-DK','E',0,'1900-01-01','Danish (da)'),
    ('Dutch (nl)','nl','nl-BE','E',0,'1900-01-01','Dutch (nl)'),
    ('Dutch (nl)','nl','nl-NL','E',0,'1900-01-01','Dutch (nl)'),
    ('English (en)','en','en-AU','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-CA','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-IN','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-IE','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-MT','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-NZ','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-PH','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-SG','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-ZA','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-GB','E',0,'1900-01-01','English (en)'),
    ('English (en)','en','en-US','E',1,'1900-01-01','English (en)'),
    ('Estonian (et)','et','et-EE','E',0,'1900-01-01','Estonian (et)'),
    ('Finnish (fi)','fi','fi-FI','E',0,'1900-01-01','Finnish (fi)'),
    ('French (fr)','fr','fr-BE','F',0,'1900-01-01','French (fr)'),
    ('French (fr)','fr','fr-CA','F',0,'1900-01-01','French (fr)'),
    ('French (fr)','fr','fr-FR','F',1,'1900-01-01','French (fr)'),
    ('French (fr)','fr','fr-LU','F',0,'1900-01-01','French (fr)'),
    ('French (fr)','fr','fr-CH','F',0,'1900-01-01','French (fr)'),
    ('German (de)','de','de-AT','G',0,'1900-01-01','German (de)'),
    ('German (de)','de','de-DE','G',1,'1900-01-01','German (de)'),
    ('German (de)','de','de-LU','G',0,'1900-01-01','German (de)'),
    ('German (de)','de','de-CH','G',0,'1900-01-01','German (de)'),
    ('Greek (el)','el','el-CY','E',0,'1900-01-01','Greek (el)'),
    ('Greek (el)','el','el-GR','E',0,'1900-01-01','Greek (el)'),
    ('Hebrew (iw)','iw','iw-IL','Z',1,'1900-01-01','Hebrew (iw)'),
    ('Hindi (hi)','hi','hi-IN','E',0,'1900-01-01','Hindi (hi)'),
    ('Hungarian (hu)','hu','hu-HU','E',0,'1900-01-01','Hungarian (hu)'),
    ('Icelandic (is)','is','is-IS','E',0,'1900-01-01','Icelandic (is)'),
    ('Indonesian (id)','id','id-ID','8',1,'1900-01-01','Indonesian (id)'),
    ('Irish (ga)','ga','ga-IE','E',0,'1900-01-01','Irish (ga)'),
    ('Italian (it)','it','it-IT','L',1,'1900-01-01','Italian (it)'),
    ('Italian (it)','it','it-CH','L',0,'1900-01-01','Italian (it)'),
    ('Japanese (ja)','ja','ja-JP','J',1,'1900-01-01','Japanese (ja)'),
    ('Japanese (ja)','ja','ja-JP-u-ca-japanese','E',0,'1900-01-01','Japanese (ja)'),
    ('Japanese (ja)','ja','ja-JP-x-lvariant-JP','E',0,'1900-01-01','Japanese (ja)'),
    ('Kazakh (kk)','kk','kk-KZ','8B',1,'1900-01-01','Kazakh (kk)'),
    ('Korean (ko)','ko','ko-KR','K',1,'1900-01-01','Korean (ko)'),
    ('Latvian (lv)','lv','lv-LV','E',0,'1900-01-01','Latvian (lv)'),
    ('Lithuanian (lt)','lt','lt-LT','E',0,'1900-01-01','Lithuanian (lt)'),
    ('Macedonian (mk)','mk','mk-MK','E',0,'1900-01-01','Macedonian (mk)'),
    ('Malaysian (ms)','ms','ms-MY','9M',1,'1900-01-01','Malaysian (ms)'),
    ('Maltese (mt)','mt','mt-MT','E',0,'1900-01-01','Maltese (mt)'),
    ('Norwegian (no)','no','no-NO','N',1,'1900-01-01','Norwegian (no)'),
    ('Norwegian Bokmål (nb)','nb','nb-NO','E',0,'1900-01-01','Norwegian Bokmål (nb)'),
    ('Norwegian Nynorsk (nn)','nn','nn-NO','E',0,'1900-01-01','Norwegian Nynorsk (nn)'),
    ('Norwegian (no)','no','no-NO-x-lvariant-NY','E',0,'1900-01-01','Norwegian (no)'),
    ('Polish (pl)','pl','pl-PL','X',1,'1900-01-01','Polish (pl)'),
    ('Portuguese (pt)','pt','pt-BR','P',1,'1900-01-01','Portuguese (pt)'),
    ('Portuguese (pt)','pt','pt-PT','P',0,'1900-01-01','Portuguese (pt)'),
    ('Romanian (ro)','ro','ro-RO','E',0,'1900-01-01','Romanian (ro)'),
    ('Russian (ru)','ru','ru-RU','R',1,'1900-01-01','Russian (ru)'),
    ('Serbian (sr)','sr','sr-BA','E',0,'1900-01-01','Serbian (sr)'),
    ('Serbian (sr)','sr','sr-ME','E',0,'1900-01-01','Serbian (sr)'),
    ('Serbian (sr)','sr','sr-RS','E',0,'1900-01-01','Serbian (sr)'),
    ('Serbian (sr)','sr','sr-Latn-BA','E',0,'1900-01-01','Serbian (sr)'),
    ('Serbian (sr)','sr','sr-Latn-ME','E',0,'1900-01-01','Serbian (sr)'),
    ('Serbian (sr)','sr','sr-Latn-RS','E',0,'1900-01-01','Serbian (sr)'),
    ('Slovak (sk)','sk','sk-SK','E',0,'1900-01-01','Slovak (sk)'),
    ('Slovenian (sl)','sl','sl-SI','E',0,'1900-01-01','Slovenian (sl)'),
    ('Spanish (es)','es','es-AR','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-BO','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-CL','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-CO','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-CR','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-DO','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-EC','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-SV','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-GT','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-HN','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-MX','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-NI','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-PA','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-PY','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-PE','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-PR','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-ES','S',1,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-US','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-UY','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-VE','S',0,'1900-01-01','Spanish (es)'),
    ('Spanish (es)','es','es-XL','S',0,'1900-01-01','Spanish (es)'),
    ('Swedish (sv)','sv','sv-SE','E',0,'1900-01-01','Swedish (sv)'),
    ('Thai (th)','th','th-TH','U',0,'1900-01-01','Thai (th)'),
    ('Thai (th)','th','th-TH-u-ca-buddhist','E',0,'1900-01-01','Thai (th)'),
    ('Thai (th)','th','th-TH-u-ca-buddhist-nu-thai','E',0,'1900-01-01','Thai (th)'),
    ('Thai (th)','th','th-TH-x-lvariant-TH','E',0,'1900-01-01','Thai (th)'),
    ('Turkish (tr)','tr','tr-TR','E',0,'1900-01-01','Turkish (tr)'),
    ('Turkmen (tk)','tk','tk-TM','8A',1,'1900-01-01','Turkmen (tk)'),
    ('Ukrainian (uk)','uk','uk-UA','9W',1,'1900-01-01','Ukrainian (uk)'),
    ('Vietnamese (vi)','vi','vi-VN','V',0,'1900-01-01','Vietnamese (vi)')


--select 'SerialNumberPrefix' Table_Name, count(*) Record_Count from [sis_stage].SerialNumberPrefix

    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Language_Details Load', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Language_Key] (Language_Tag)
Select s.Language_Tag
From [sis_stage].[Language_Details] s
    Left outer join [sis_stage].[Language_Key] k on s.Language_Tag = k.Language_Tag
Where k.Language_ID is null

--Key table load

    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Language Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Language_ID = k.Language_ID
    From [sis_stage].[Language_Details] s
inner join [sis_stage].[Language_Key] k on s.Language_Tag = k.Language_Tag
where s.Language_ID is null

--Surrogate Update
    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Language_Details Update Surrogate', @DATAVALUE = @@RowCount;


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
