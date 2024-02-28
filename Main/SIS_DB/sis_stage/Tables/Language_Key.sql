CREATE TABLE [sis_stage].[Language_Key] (
    [Language_ID]  INT          IDENTITY (1, 1) NOT NULL,
    [Language_Tag] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Language_Key] PRIMARY KEY CLUSTERED ([Language_ID] ASC)
);