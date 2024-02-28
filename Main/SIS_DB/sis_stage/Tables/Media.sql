CREATE TABLE [sis_stage].[Media] (
    [Media_ID]                  INT          NULL,
    [Media_Number]              VARCHAR (50) NOT NULL,
    [Source]                    VARCHAR (50) NULL,
    [Safety_Document_Indicator] BIT          NULL,
    [PIPPS_Number]              VARCHAR (50) NULL,
    [Termination_Date]          DATE         NULL,
    CONSTRAINT [PK_Manual] PRIMARY KEY CLUSTERED ([Media_Number] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [IX_Media_MediaNumber]
    ON [sis_stage].[Media]([Media_Number] ASC, [Media_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Media_Media_ID]
    ON [sis_stage].[Media]([Media_ID] ASC);

