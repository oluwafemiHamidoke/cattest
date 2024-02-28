CREATE TABLE [sis_stage].[Media_HTML5] (
    [Media_ID]                  INT          NULL,
    [Media_Number]              VARCHAR (50) NOT NULL,
    [Source]                    VARCHAR (50) NULL,
    [Safety_Document_Indicator] BIT          NULL,
    [PIPPS_Number]              VARCHAR (50) NULL,
    CONSTRAINT [PK_Manual_HTML5] PRIMARY KEY CLUSTERED ([Media_Number] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [IX_Media_HTML5_MediaNumber]
    ON [sis_stage].[Media]([Media_Number] ASC, [Media_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Media_HTML5_Media_ID]
    ON [sis_stage].[Media]([Media_ID] ASC);

