CREATE TABLE [sissearch2].[ExpandedMiningProductParts] (
    [ID]                               [varchar](50)    NOT NULL,
    [IESystemControlNumber]            [varchar](50)    NULL,
    [InsertDate]                       [datetime]       NULL,
    [InformationType]                  [varchar](10)    NULL,
    [MediaNumber]                      [varchar](15)    NULL,
    [IEUpdateDate]                     [datetime2](0)   NULL,
    [IEPart]                           [nvarchar](700)  NULL,
    [IEPartNumber]                     [varchar](40)    NULL,
    [PartsManualMediaNumber]           [varchar](15)    NULL,
    [IECaption]                        [nvarchar](2048) NULL,
    [ConsistPart]                      [nvarchar](max)  NULL,
    [System]                           [varchar](max)   NULL,
    [SystemPSID]                       [varchar](max)   NULL,
    [PSID]                             [varchar](max)   NULL,
    [SerialNumbers]                    [varchar](max)   NULL,
    [ProductInstanceNumbers]           [varchar](max)   NULL,
    [isMedia]                          [bit]            NULL,
    [PubDate]                          [datetime]       NULL,
    [ControlNumber]                    [varchar](50)    NULL,
    [GraphicControlNumber]             [varchar](MAX)   NULL,
    [familyCode]                       [varchar](max)   NULL,
    [familySubFamilyCode]              [varchar](max)   NULL,
    [familySubFamilySalesModel]        [varchar](max)   NULL,
    [familySubFamilySalesModelSNP]     [varchar](max)   NULL,
    [ConsistPartNames_es-ES]           [nvarchar](max)  NULL,
    [ConsistPartNames_zh-CN]           [nvarchar](max)  NULL,
    [ConsistPartNames_fr-FR]           [nvarchar](max)  NULL,
    [ConsistPartNames_it-IT]           [nvarchar](max)  NULL,
    [ConsistPartNames_de-DE]           [nvarchar](max)  NULL,
    [ConsistPartNames_pt-BR]           [nvarchar](max)  NULL,
    [ConsistPartNames_id-ID]           [nvarchar](max)  NULL,
    [ConsistPartNames_ja-JP]           [nvarchar](max)  NULL,
    [ConsistPartNames_ru-RU]           [nvarchar](max)  NULL,
    [MediaOrigin]                      [varchar](2)     NULL,
    [OrgCode]                          [varchar](12)    NULL,
    CONSTRAINT [PK_EXPANDEDMININGPRODUCTPARTS] PRIMARY KEY CLUSTERED ([ID] ASC)
    );
GO

CREATE NONCLUSTERED INDEX [IX_sissearch_2_ExpandedMiningProductParts_PARTNUMBER_ORGCODE]
    ON [sissearch2].[ExpandedMiningProductParts]([IEPartNumber] ASC, [OrgCode] ASC);
GO