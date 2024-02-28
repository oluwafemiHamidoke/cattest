CREATE TABLE [sis].[SerialNumberRange] (
    [SerialNumberRange_ID] INT NOT NULL,
    [Start_Serial_Number]  INT NOT NULL,
    [End_Serial_Number]    INT NOT NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_SerialNumberRange] PRIMARY KEY CLUSTERED ([SerialNumberRange_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_Start_End]
    ON [sis].[SerialNumberRange]([Start_Serial_Number] ASC, [End_Serial_Number] ASC);



