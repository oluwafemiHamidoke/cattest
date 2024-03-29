﻿CREATE TABLE [SISSEARCH].[CONSOLIDATEDSERVICEIE_4] (
    [ID]                           VARCHAR (50)    NOT NULL,
    [IESystemControlNumber]        VARCHAR (15)    NOT NULL,
    [InfoType]                     VARCHAR (4000)  NULL,
    [MediaNumbers]                 VARCHAR (MAX)   NULL,
    [UpdatedDate]                  DATE            NULL,
    [SerialNumbers]                VARCHAR (MAX)   NULL,
    [SMCSCodes]                    VARCHAR (MAX)   NULL,
    [ProductStructureSystemIDs]    VARCHAR (MAX)   NULL,
    [Title_en]                     NVARCHAR (4000) NULL,
    [isMedia]                      BIT             NULL,
    [Profile]                      VARCHAR (MAX)   NULL,
    [ProductCodes]                 VARCHAR (MAX)   NULL,
    [InsertDate]                   DATETIME        NOT NULL,
    [PubDate]                      DATETIME2 (7)   NOT NULL,
    [RestrictionCode]              VARCHAR (MAX)   NULL,
    [ControlNumber]                VARCHAR (4000)  NULL,
    [familyCode]                   VARCHAR (MAX)   NULL,
    [familySubFamilyCode]          VARCHAR (MAX)   NULL,
    [familySubFamilySalesModel]    VARCHAR (MAX)   NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX)   NULL,
    [Title_es-ES]                  NVARCHAR (4000) NULL,
    [Title_zh-CN]                  NVARCHAR (4000) NULL,
    [Title_fr-FR]                  NVARCHAR (4000) NULL,
    [Title_it-IT]                  NVARCHAR (4000) NULL,
    [Title_de-DE]                  NVARCHAR (4000) NULL,
    [Title_pt-BR]                  NVARCHAR (4000) NULL,
    [Title_id-ID]                  NVARCHAR (4000) NULL,
    [Title_ja-JP]                  NVARCHAR (4000) NULL,
    [Title_ru-RU]                  NVARCHAR (4000) NULL,
    [PubDate_es-ES]                DATETIME2 (7)   NULL,
    [PubDate_zh-CN]                DATETIME2 (7)   NULL,
    [PubDate_fr-FR]                DATETIME2 (7)   NULL,
    [PubDate_it-IT]                DATETIME2 (7)   NULL,
    [PubDate_de-DE]                DATETIME2 (7)   NULL,
    [PubDate_pt-BR]                DATETIME2 (7)   NULL,
    [PubDate_id-ID]                DATETIME2 (7)   NULL,
    [PubDate_ja-JP]                DATETIME2 (7)   NULL,
    [PubDate_ru-RU]                DATETIME2 (7)   NULL,
    [UpdatedDate_es-ES]            DATE            NULL,
    [UpdatedDate_zh-CN]            DATE            NULL,
    [UpdatedDate_fr-FR]            DATE            NULL,
    [UpdatedDate_it-IT]            DATE            NULL,
    [UpdatedDate_de-DE]            DATE            NULL,
    [UpdatedDate_pt-BR]            DATE            NULL,
    [UpdatedDate_id-ID]            DATE            NULL,
    [UpdatedDate_ja-JP]            DATE            NULL,
    [UpdatedDate_ru-RU]            DATE            NULL,
    [MediaNumbers_es-ES]           VARCHAR (MAX)   NULL,
    [MediaNumbers_zh-CN]           VARCHAR (MAX)   NULL,
    [MediaNumbers_fr-FR]           VARCHAR (MAX)   NULL,
    [MediaNumbers_it-IT]           VARCHAR (MAX)   NULL,
    [MediaNumbers_de-DE]           VARCHAR (MAX)   NULL,
    [MediaNumbers_pt-BR]           VARCHAR (MAX)   NULL,
    [MediaNumbers_id-ID]           VARCHAR (MAX)   NULL,
    [MediaNumbers_ja-JP]           VARCHAR (MAX)   NULL,
    [MediaNumbers_ru-RU]           VARCHAR (MAX)   NULL,
    [mediaOrigin]                  VARCHAR (2)     NULL,
    [GraphicControlNumber]         VARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) 
);





GO
ALTER TABLE [SISSEARCH].[CONSOLIDATEDSERVICEIE_4] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

