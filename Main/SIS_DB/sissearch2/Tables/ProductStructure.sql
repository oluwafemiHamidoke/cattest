CREATE TABLE [sissearch2].[ProductStructure] (
    [IESystemControlNumber] VARCHAR (50)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [System]                VARCHAR (MAX) NULL,
    [SystemPSID]            VARCHAR (MAX) NULL,
    [PSID]                  VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);
