CREATE TABLE [sis_stage].[InfoType_Translation_Diff] (
    [Operation]   VARCHAR (50)   NOT NULL,
    [InfoType_ID] INT            NOT NULL,
    [Language_ID] INT            NOT NULL,
    [Description] NVARCHAR (720) NULL,
    CONSTRAINT [PK_InfoType_Translation_Diff] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC, [Language_ID] ASC)
);

