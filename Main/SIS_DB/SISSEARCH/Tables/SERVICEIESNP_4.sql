CREATE TABLE [SISSEARCH].[SERVICEIESNP_4] (
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [SerialNumbers]         VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);
