CREATE TABLE [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS] (
	[ID]                               [varchar](50) NOT NULL,
	[Iesystemcontrolnumber]            [varchar](50) NULL,
	[INSERTDATE]                       [datetime] NULL,
	[InformationType]                  [varchar](10) NULL,
	[Medianumber]                      [varchar](15) NULL,
	[IEupdatedate]                     [datetime2](0) NULL,
	[IEpart]                           [nvarchar](700) NULL,
    [IEpartNumber]                     [varchar](40) NULL,
	[PARTSMANUALMEDIANUMBER]           [varchar](15) NULL,
	[IECAPTION]                        [nvarchar](2048) NULL,
	[CONSISTPART]                      [nvarchar](max) NULL,
	[SYSTEM]                           [varchar](max) NULL,
    [SYSTEMPSID]                       [varchar](max) NULL,
    [PSID]                             [varchar](max) NULL,
	[SerialNumbers]                    [varchar](max) NULL,
	[ProductInstanceNumbers]           [varchar](max) NULL,
	[isMedia]                          [bit] NULL,
	[PubDate]                          [datetime] NULL,
	[ControlNumber]                    [varchar](50) NULL,
	[familyCode]                       [varchar](max) NULL,
	[familySubFamilyCode]              [varchar](max) NULL,
	[familySubFamilySalesModel]        [varchar](max) NULL,
	[familySubFamilySalesModelSNP]     [varchar](max) NULL,
	[ConsistPartNames_es-ES]           [nvarchar](max) NULL,
	[ConsistPartNames_zh-CN]           [nvarchar](max) NULL,
	[ConsistPartNames_fr-FR]           [nvarchar](max) NULL,
	[ConsistPartNames_it-IT]           [nvarchar](max) NULL,
	[ConsistPartNames_de-DE]           [nvarchar](max) NULL,
	[ConsistPartNames_pt-BR]           [nvarchar](max) NULL,
	[ConsistPartNames_id-ID]           [nvarchar](max) NULL,
	[ConsistPartNames_ja-JP]           [nvarchar](max) NULL,
	[ConsistPartNames_ru-RU]           [nvarchar](max) NULL,
	[mediaOrigin]                      [varchar](2) NULL,
    [orgCode]                          [varchar](12)   NULL,
	[GraphicControlNumber] 				[varchar](max) NULL,
	CONSTRAINT [PK_EXPANDEDMININGPRODUCTPARTS] PRIMARY KEY CLUSTERED ([ID] ASC)
	);
GO

CREATE NONCLUSTERED INDEX [IX_EXPANDEDMININGPRODUCTPARTS_PARTNUMBER_ORGCODE]
    ON [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]([IEpartNumber] ASC, [orgCode] ASC);
GO