CREATE TABLE [SISSEARCH].[SERVICEIESMCS_2] (
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [SMCSCompCode]          VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);