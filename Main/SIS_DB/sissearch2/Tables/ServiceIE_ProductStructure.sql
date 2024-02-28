CREATE TABLE [sissearch2].[ServiceIE_ProductStructure](
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [System]                VARCHAR (MAX) NULL,
    [SystemPSID]            VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

