
 Create view [EXTERNAL].[vw_PartsIE_Metadata]
 as
SELECT [ID]
      ,[Iesystemcontrolnumber]
      ,[INSERTDATE]
      ,[InformationType]
      ,[Medianumber]
      ,[IEupdatedate]
      ,[IEpart]
      ,[PARTSMANUALMEDIANUMBER]
      ,[IECAPTION]
      ,[CONSISTPART]
      ,[SYSTEM]
      ,[SYSTEMPSID]
      ,[PSID]
      ,[smcs]
      ,[SerialNumbers]
      ,[isMedia]
      ,[Profile]
      ,[PubDate]
      ,[REMANCONSISTPART]
      ,[REMANIEPART]
      ,[YELLOWMARKCONSISTPART]
      ,[YELLOWMARKIEPART]
      ,[KITCONSISTPART]
      ,[KITIEPART]
      ,[ControlNumber]
      ,[IePartHistory]
      ,[ConsistPartHistory]
      ,[IePartReplacement]
      ,[ConsistPartReplacement]
      ,[IEPartName_es-ES]
      ,[IEPartName_zh-CN]
      ,[IEPartName_fr-FR]
      ,[IEPartName_it-IT]
      ,[IEPartName_de-DE]
      ,[IEPartName_pt-BR]
      ,[IEPartName_id-ID]
      ,[IEPartName_ja-JP]
      ,[IEPartName_ru-RU]
      ,[ConsistPartNames_es-ES]
      ,[ConsistPartNames_zh-CN]
      ,[ConsistPartNames_fr-FR]
      ,[ConsistPartNames_it-IT]
      ,[ConsistPartNames_de-DE]
      ,[ConsistPartNames_pt-BR]
      ,[ConsistPartNames_id-ID]
      ,[ConsistPartNames_ja-JP]
      ,[ConsistPartNames_ru-RU]
  FROM [SISSEARCH].[CONSOLIDATEDPARTS_4]