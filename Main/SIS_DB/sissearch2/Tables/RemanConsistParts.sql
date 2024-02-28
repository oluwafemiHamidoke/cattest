CREATE TABLE [sissearch2].[RemanConsistParts] (
    [IESystemControlNumber] VARCHAR (12)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [RemanConsistPart]      VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);