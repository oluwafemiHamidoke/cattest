CREATE TABLE [SISSEARCH].[CONSOLIDATEDPARTS_4] (
    [ID]                                VARCHAR (50)   NOT NULL,
    [Iesystemcontrolnumber]             VARCHAR (50)   NULL,
    [INSERTDATE]                        DATETIME       NULL,
    [InformationType]                   VARCHAR (10)   NULL,
    [Medianumber]                       VARCHAR (15)   NULL,
    [IEupdatedate]                      DATETIME2 (0)  NULL,
    [IEpart]                            NVARCHAR (700)  NULL,
    [PARTSMANUALMEDIANUMBER]            VARCHAR (15)   NULL,
    [IECAPTION]                         NVARCHAR (2048) NULL,
    [CONSISTPART]                       NVARCHAR (MAX) NULL,
    [SYSTEM]                            VARCHAR (MAX)  NULL,
    [SYSTEMPSID]                        VARCHAR (MAX)  NULL,
    [PSID]                              VARCHAR (MAX)  NULL,
    [smcs]                              VARCHAR (MAX)  NULL,
    [SerialNumbers]                     VARCHAR (MAX)  NULL,
    [ProductInstanceNumbers]            VARCHAR (MAX)  NULL,
    [isMedia]                           BIT            NULL,
    [Profile]                           VARCHAR (MAX)  NULL,
    [PubDate]                           DATETIME       NULL,
    [REMANCONSISTPART]                  VARCHAR (MAX)  NULL,
    [REMANIEPART]                       VARCHAR (MAX)  NULL,
    [YELLOWMARKCONSISTPART]             VARCHAR (MAX)  NULL,
    [YELLOWMARKIEPART]                  VARCHAR (MAX)  NULL,
    [KITCONSISTPART]                    VARCHAR (MAX)  NULL,
    [KITIEPART]                         VARCHAR (MAX)  NULL,
    [ControlNumber]                     VARCHAR (50)   NULL,
    [familyCode]                        VARCHAR (MAX)  NULL,
    [familySubFamilyCode]               VARCHAR (MAX)  NULL,
    [familySubFamilySalesModel]         VARCHAR (MAX)  NULL,
    [familySubFamilySalesModelSNP]      VARCHAR (MAX)  NULL,
    [IePartHistory]                     VARCHAR (MAX)  NULL,
    [ConsistPartHistory]                VARCHAR (MAX)  NULL,
    [IePartReplacement]                 VARCHAR (MAX)  NULL,
    [ConsistPartReplacement]            VARCHAR (MAX)  NULL,
    [IEPartName_es-ES]                  NVARCHAR (150)  NULL,
    [IEPartName_zh-CN]                  NVARCHAR (150)  NULL,
    [IEPartName_fr-FR]                  NVARCHAR (150)  NULL,
    [IEPartName_it-IT]                  NVARCHAR (150)  NULL,
    [IEPartName_de-DE]                  NVARCHAR (150)  NULL,
    [IEPartName_pt-BR]                  NVARCHAR (150)  NULL,
    [IEPartName_id-ID]                  NVARCHAR (150)  NULL,
    [IEPartName_ja-JP]                  NVARCHAR (150)  NULL,
    [IEPartName_ru-RU]                  NVARCHAR (150)  NULL,
    [ConsistPartNames_es-ES]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_zh-CN]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_fr-FR]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_it-IT]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_de-DE]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_pt-BR]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_id-ID]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_ja-JP]            NVARCHAR (MAX) NULL,
    [ConsistPartNames_ru-RU]            NVARCHAR (MAX) NULL,
    [mediaOrigin]                       VARCHAR (2)    NULL,
    [orgCode]				  			VARCHAR(12)	   NULL,
    [isExpandedMiningProduct]           BIT            NOT NULL DEFAULT(0),
    CONSTRAINT [PK_CONSOLIDATEDPARTS_4] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO

CREATE NONCLUSTERED INDEX [IX_CONSOLIDATEDPARTS_4_PARTNUMBER]
    ON [SISSEARCH].[CONSOLIDATEDPARTS_4]([Iesystemcontrolnumber] ASC) ;



GO

ALTER TABLE [SISSEARCH].[CONSOLIDATEDPARTS_4] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
