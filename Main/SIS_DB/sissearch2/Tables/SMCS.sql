CREATE TABLE [sissearch2].[SMCS] (
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (50)  NOT NULL,
    [SMCS]                  VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);