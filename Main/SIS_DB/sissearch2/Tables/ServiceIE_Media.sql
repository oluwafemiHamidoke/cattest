CREATE TABLE[sissearch2].[ServiceIE_Media] (
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [MediaNumber]           VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    [MediaNumbers_es-ES]    VARCHAR (MAX) NULL,
    [MediaNumbers_zh-CN]    VARCHAR (MAX) NULL,
    [MediaNumbers_fr-FR]    VARCHAR (MAX) NULL,
    [MediaNumbers_it-IT]    VARCHAR (MAX) NULL,
    [MediaNumbers_de-DE]    VARCHAR (MAX) NULL,
    [MediaNumbers_pt-BR]    VARCHAR (MAX) NULL,
    [MediaNumbers_id-ID]    VARCHAR (MAX) NULL,
    [MediaNumbers_ja-JP]    VARCHAR (MAX) NULL,
    [MediaNumbers_ru-RU]    VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);