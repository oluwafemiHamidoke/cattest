CREATE TABLE [sis_stage].[SerialNumberRange_Key] (
    [SerialNumberRange_ID] INT IDENTITY (1, 1) NOT NULL,
    [Start_Serial_Number]  INT NOT NULL,
    [End_Serial_Number]    INT NOT NULL,
    CONSTRAINT [PK_Effectivity_Key] PRIMARY KEY CLUSTERED ([SerialNumberRange_ID] ASC)
);