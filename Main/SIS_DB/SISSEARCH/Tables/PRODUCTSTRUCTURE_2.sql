CREATE TABLE [SISSEARCH].[PRODUCTSTRUCTURE_2] (
    [Iesystemcontrolnumber] VARCHAR (50)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [SYSTEM]                VARCHAR (MAX) NULL,
    [SYSTEMPSID]            VARCHAR (MAX) NULL,
    [PSID]                  VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);
