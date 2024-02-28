CREATE TABLE [sissearch2].[RemanIEPart] (
    [IESystemControlNumber] VARCHAR (50)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [RemanIEPart]           VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);