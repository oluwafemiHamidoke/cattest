CREATE TABLE [sis_stage].[AsShippedEngine] (
    [AsShippedEngine_ID]    INT         NULL,
    [Part_ID]               INT         NOT NULL,
    [SerialNumberPrefix_ID] INT         NOT NULL,
    [SerialNumberRange_ID]  INT         NOT NULL,
    [Quantity]              INT         NOT NULL,
    [Sequence_Number]       INT         NOT NULL,
    [Change_Level_Number]   VARCHAR (4) NULL,
    [Assembly]              VARCHAR (1) NULL,
    [Less_Indicator]        VARCHAR (1) NULL,
    [Indentation]           VARCHAR (1) NULL,
    CONSTRAINT [PK_AsShippedEngine] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Sequence_Number] ASC)
);