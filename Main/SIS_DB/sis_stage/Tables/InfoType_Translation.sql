CREATE TABLE [sis_stage].[InfoType_Translation] (
    [InfoType_ID] INT            NOT NULL,
    [Language_ID] INT            NOT NULL,
    [Description] NVARCHAR (720) NULL,
    CONSTRAINT [PK_InfoType_Translation] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC, [Language_ID] ASC)
);

