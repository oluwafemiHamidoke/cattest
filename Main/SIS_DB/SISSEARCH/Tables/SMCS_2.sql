CREATE TABLE [SISSEARCH].[SMCS_2] (
    [ID]                    VARCHAR (50)  NOT NULL,
    [Iesystemcontrolnumber] VARCHAR (50)  NOT NULL,
    [smcs]                  VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);