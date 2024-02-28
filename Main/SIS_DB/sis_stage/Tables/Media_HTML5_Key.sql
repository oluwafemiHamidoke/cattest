CREATE TABLE [sis_stage].[Media_HTML5_Key] (
    [Media_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Media_Number] VARCHAR (50) NOT NULL,
    [Source]       VARCHAR (50) NULL,
    CONSTRAINT [PK_Media_HTML5_Key] PRIMARY KEY CLUSTERED ([Media_ID] ASC) WITH (FILLFACTOR = 100)
);

