
CREATE   VIEW [SISSEARCH].[vw_BASICPARTS] AS
SELECT [ID]
      ,[Iesystemcontrolnumber]
      --,[BeginRange]
      --,[EndRange]
      ,[InformationType]
      ,[medianumber]
      ,ieupdatedate
      ,iepart
      ,[PARTSMANUALMEDIANUMBER]
	  ,[IECAPTION]
      ,[InsertDate]
	  ,0 as isMedia
	  ,[PubDate]
	  ,ControlNumber
	  ,[iePartName_es-ES]
	  ,[iePartName_zh-CN] 
	  ,[iePartName_fr-FR] 
	  ,[iePartName_it-IT] 
	  ,[iePartName_de-DE] 
	  ,[iePartName_pt-BR]
  	  ,[iePartName_id-ID]
	  ,[iePartName_ja-JP]
	  ,[iePartName_ru-RU] 
From [SISSEARCH].[vw_BASICPARTSORIGIN]
WHERE RowRank=1