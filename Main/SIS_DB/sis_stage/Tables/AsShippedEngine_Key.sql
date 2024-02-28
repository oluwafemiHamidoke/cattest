CREATE TABLE [sis_stage].[AsShippedEngine_Key] (
    [AsShippedEngine_ID]    INT IDENTITY (1, 1) NOT NULL,
    [Part_ID]               INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL,
    [Sequence_Number]       INT NOT NULL,
    CONSTRAINT [PK_AsShippedEngine_Key] PRIMARY KEY CLUSTERED ([AsShippedEngine_ID] ASC)
);