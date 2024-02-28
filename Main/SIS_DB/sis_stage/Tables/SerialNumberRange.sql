CREATE TABLE [sis_stage].[SerialNumberRange] (
    [SerialNumberRange_ID] INT NULL,
    [Start_Serial_Number]  INT NOT NULL,
    [End_Serial_Number]    INT NOT NULL,
    CONSTRAINT [PK_Effectivity] PRIMARY KEY CLUSTERED ([Start_Serial_Number] ASC, [End_Serial_Number] ASC)
);
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_Start_End] ON [sis_stage].[SerialNumberRange]
(
	[Start_Serial_Number] ASC,
	[End_Serial_Number] ASC
);