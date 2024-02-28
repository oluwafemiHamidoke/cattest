CREATE TABLE [sissearch2].[Basic_Parts] (
    [ID]                     VARCHAR (50)   NOT NULL,
    [IESystemControlNumber]  VARCHAR (50)   NOT NULL,
    [InformationType]        VARCHAR (10)   NULL,
    [MediaNumber]            VARCHAR (15)   NULL,
    [IEUpdateDate]           DATETIME2 (0)  NOT NULL,
    [IEPart]                 NVARCHAR (700) NULL,
    [IEPartNumber]           VARCHAR (40)   NULL,
    [PartsManualMediaNumber] VARCHAR (15)   NULL,
    [IECaption]              NVARCHAR(2048) NULL,
    [InsertDate]             DATETIME       NOT NULL,
    [isMedia]                BIT            NOT NULL,
    [PubDate]                DATETIME       NULL,
    [ControlNumber]          VARCHAR (50)   NULL,
    [GraphicControlNumber]   VARCHAR (MAX)  NULL,
    [IEPartName_es-ES]       NVARCHAR (150) NULL,
    [IEPartName_zh-CN]       NVARCHAR (150) NULL,
    [IEPartName_fr-FR]       NVARCHAR (150) NULL,
    [IEPartName_it-IT]       NVARCHAR (150) NULL,
    [IEPartName_de-DE]       NVARCHAR (150) NULL,
    [IEPartName_pt-BR]       NVARCHAR (150) NULL,
    [IEPartName_id-ID]       NVARCHAR (150) NULL,
    [IEPartName_ja-JP]       NVARCHAR (150) NULL,
    [IEPartName_ru-RU]       NVARCHAR (150) NULL,
    [MediaOrigin]            VARCHAR (2)    NULL,
    [OrgCode]				 VARCHAR (12)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Basic_Parts_IEPartNumber_OrgCode]
    ON [sissearch2].[Basic_Parts]([IEPartNumber] ASC, [OrgCode] ASC);
GO
