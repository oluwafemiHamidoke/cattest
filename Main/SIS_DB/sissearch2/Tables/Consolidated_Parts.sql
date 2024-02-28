CREATE TABLE [sissearch2].[Consolidated_Parts] (
    [ID]                                VARCHAR (50)    NOT NULL,
    [IESystemControlNumber]             VARCHAR (50)    NULL,
    [InsertDate]                        DATETIME        NULL,
    [InformationType]                   VARCHAR (10)    NULL,
    [MediaNumber]                       VARCHAR (15)    NULL,
    [IEUpdateDate]                      DATETIME2 (0)   NULL,
    [IEPart]                            NVARCHAR (700)  NULL,
    [PartsManualMediaNumber]            VARCHAR (15)    NULL,
    [IECaption]                         NVARCHAR (2048) NULL,
    [ConsistPart]                       NVARCHAR (MAX)  NULL,
    [System]                            VARCHAR (MAX)   NULL,
    [SystemPSID]                        VARCHAR (MAX)   NULL,
    [PSID]                              VARCHAR (MAX)   NULL,
    [SMCS]                              VARCHAR (MAX)   NULL,
    [SerialNumbers]                     VARCHAR (MAX)   NULL,
    [ProductInstanceNumbers]            VARCHAR (MAX)   NULL,
    [IsMedia]                           BIT             NULL,
    [Profile]                           VARCHAR (MAX)   NULL,
    [PubDate]                           DATETIME        NULL,
    [REMANConsistPart]                  VARCHAR (MAX)   NULL,
    [REMANIEPart]                       VARCHAR (MAX)   NULL,
    [YellowMarkConsistPart]             VARCHAR (MAX)   NULL,
    [YellowMarkIEPart]                  VARCHAR (MAX)   NULL,
    [KITConsistPart]                    VARCHAR (MAX)   NULL,
    [KITIEPart]                         VARCHAR (MAX)   NULL,
    [ControlNumber]                     VARCHAR (50)    NULL,
    [GraphicControlNumber]              VARCHAR (MAX)   NULL,
    [FamilyCode]                        VARCHAR (MAX)   NULL,
    [FamilySubFamilyCode]               VARCHAR (MAX)   NULL,
    [FamilySubFamilySalesModel]         VARCHAR (MAX)   NULL,
    [FamilySubFamilySalesModelSNP]      VARCHAR (MAX)   NULL,
    [IEPartHistory]                     VARCHAR (MAX)   NULL,
    [ConsistPartHistory]                VARCHAR (MAX)   NULL,
    [IEPartReplacement]                 VARCHAR (MAX)   NULL,
    [ConsistPartReplacement]            VARCHAR (MAX)   NULL,
    [IEPartName_es-ES]                  NVARCHAR (150)  NULL,
    [IEPartName_zh-CN]                  NVARCHAR (150)  NULL,
    [IEPartName_fr-FR]                  NVARCHAR (150)  NULL,
    [IEPartName_it-IT]                  NVARCHAR (150)  NULL,
    [IEPartName_de-DE]                  NVARCHAR (150)  NULL,
    [IEPartName_pt-BR]                  NVARCHAR (150)  NULL,
    [IEPartName_id-ID]                  NVARCHAR (150)  NULL,
    [IEPartName_ja-JP]                  NVARCHAR (150)  NULL,
    [IEPartName_ru-RU]                  NVARCHAR (150)  NULL,
    [ConsistPartNames_es-ES]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_zh-CN]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_fr-FR]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_it-IT]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_de-DE]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_pt-BR]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_id-ID]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_ja-JP]            NVARCHAR (MAX)  NULL,
    [ConsistPartNames_ru-RU]            NVARCHAR (MAX)  NULL,
    [MediaOrigin]                       VARCHAR (2)     NULL,
    [OrgCode]				  			VARCHAR(12)	    NULL,
    [IsExpandedMiningProduct]           BIT             NOT NULL DEFAULT(0),
    CONSTRAINT [PK_Consolidated_Parts] PRIMARY KEY CLUSTERED ([ID] ASC)
);

GO

CREATE NONCLUSTERED INDEX [IX_Consolidated_Parts_IESystemControlNumber]
    ON [sissearch2].[Consolidated_Parts]([IESystemControlNumber] ASC) ;

GO

ALTER TABLE [sissearch2].[Consolidated_Parts] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);
GO
