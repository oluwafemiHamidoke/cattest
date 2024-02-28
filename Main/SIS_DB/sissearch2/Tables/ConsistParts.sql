CREATE TABLE [sissearch2].[ConsistParts] (
    [IESystemControlNumber]  VARCHAR (12)   NOT NULL,
    [ID]                     VARCHAR (50)   NOT NULL,
    [ConsistPart]            NVARCHAR (MAX) NULL,
    [InsertDate]             DATETIME       NOT NULL,
    [ConsistPartNames_es-ES] NVARCHAR (MAX) NULL,
    [ConsistPartNames_zh-CN] NVARCHAR (MAX) NULL,
    [ConsistPartNames_fr-FR] NVARCHAR (MAX) NULL,
    [ConsistPartNames_it-IT] NVARCHAR (MAX) NULL,
    [ConsistPartNames_de-DE] NVARCHAR (MAX) NULL,
    [ConsistPartNames_pt-BR] NVARCHAR (MAX) NULL,
    [ConsistPartNames_id-ID] NVARCHAR (MAX) NULL,
    [ConsistPartNames_ja-JP] NVARCHAR (MAX) NULL,
    [ConsistPartNames_ru-RU] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ConsistParts] PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_ConsistParts_IESystemControlNumber]
    ON [sissearch2].[ConsistParts]([IESystemControlNumber] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_ConsistParts_InsertDate]
    ON [sissearch2].[ConsistParts]([InsertDate] ASC);
GO