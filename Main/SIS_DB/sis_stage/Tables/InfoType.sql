CREATE TABLE [sis_stage].[InfoType] (
    [InfoType_ID] INT NOT NULL,
    [Is_Structured] BIT NOT NULL DEFAULT 0 ,
    CONSTRAINT [PK_InfoType] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC)
);
GO

