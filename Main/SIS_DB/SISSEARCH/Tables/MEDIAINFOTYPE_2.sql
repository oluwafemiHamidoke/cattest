CREATE TABLE [SISSEARCH].[MEDIAINFOTYPE_2] (
    [ID]                 VARCHAR (50)  NOT NULL,
    [BaseEngMediaNumber] VARCHAR (15)  NOT NULL,
    [InformationType]    VARCHAR (MAX) NULL,
    [InsertDate]         DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);