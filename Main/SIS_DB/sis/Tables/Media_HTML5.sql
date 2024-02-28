CREATE TABLE [sis].[Media_HTML5] (
    [Media_ID]                  INT          NOT NULL,
    [Media_Number]              VARCHAR (50) NOT NULL,
    [Source]                    VARCHAR (50) NULL,
    [Safety_Document_Indicator] BIT          NULL,
    [PIPPS_Number]              VARCHAR (50) NULL,
    CONSTRAINT [PK_Manual_HTML5] PRIMARY KEY CLUSTERED ([Media_ID] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Media_HTML5]
    ON [sis].[Media_HTML5]([Media_Number] ASC);
GO
