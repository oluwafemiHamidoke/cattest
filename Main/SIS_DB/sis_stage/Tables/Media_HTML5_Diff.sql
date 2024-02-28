CREATE TABLE [sis_stage].[Media_HTML5_Diff] (
    [Operation]                 VARCHAR (50) NOT NULL,
    [Media_ID]                  INT          NULL,
    [Media_Number]              VARCHAR (50) NOT NULL,
    [Source]                    VARCHAR (50) NULL,
    [Safety_Document_Indicator] BIT          NULL,
    [PIPPS_Number]              VARCHAR (50) NULL,
    CONSTRAINT [PK_Manual_HTML5_Diff] PRIMARY KEY CLUSTERED ([Media_Number] ASC) WITH (FILLFACTOR = 100)
);

