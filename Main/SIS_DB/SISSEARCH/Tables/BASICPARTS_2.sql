CREATE TABLE [SISSEARCH].[BASICPARTS_2] (
    [ID]                     VARCHAR (50)   NOT NULL,
    [Iesystemcontrolnumber]  VARCHAR (50)   NOT NULL,
    [InformationType]        VARCHAR (10)   NULL,
    [Medianumber]            VARCHAR (15)   NULL,
    [IEupdatedate]           DATETIME2 (0)  NOT NULL,
    [IEpart]                 NVARCHAR (700)  NULL,
    [IEpartNumber]           VARCHAR (40)   NULL,
    [PARTSMANUALMEDIANUMBER] VARCHAR (15)   NULL,
    [IECAPTION]              NVARCHAR (2048) NULL,
    [InsertDate]             DATETIME       NOT NULL,
    [isMedia]                BIT            NOT NULL,
    [PubDate]                DATETIME       NULL,
    [ControlNumber]          VARCHAR (50)   NULL,
    [IEPartName_es-ES]       NVARCHAR (150)  NULL,
    [IEPartName_zh-CN]       NVARCHAR (150)  NULL,
    [IEPartName_fr-FR]       NVARCHAR (150)  NULL,
    [IEPartName_it-IT]       NVARCHAR (150)  NULL,
    [IEPartName_de-DE]       NVARCHAR (150)  NULL,
    [IEPartName_pt-BR]       NVARCHAR (150)  NULL,
    [IEPartName_id-ID]       NVARCHAR (150)  NULL,
    [IEPartName_ja-JP]       NVARCHAR (150)  NULL,
    [IEPartName_ru-RU]       NVARCHAR (150)  NULL,
    [mediaOrigin]            VARCHAR (2)    NULL,
    [orgCode]				 VARCHAR (12)   NULL,
    [GraphicControlNumber]   VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) 
);
GO

CREATE NONCLUSTERED INDEX [IX_BASICPARTS_2_PARTNUMBER_ORGCODE]
    ON [SISSEARCH].[BASICPARTS_2]([IEpartNumber] ASC, [orgCode] ASC);
GO
