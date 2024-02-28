CREATE TABLE [sis].[Media] (
    [Media_ID]                  INT          NOT NULL,
    [Media_Number]              VARCHAR (50) NOT NULL,
    [Source]                    VARCHAR (50) NULL,
    [Safety_Document_Indicator] BIT          NULL,
    [PIPPS_Number]              VARCHAR (50) NULL,
    [Termination_Date]          [DATE]      NULL, 
    CONSTRAINT [PK_Manual] PRIMARY KEY CLUSTERED ([Media_ID] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Media]
    ON [sis].[Media]([Media_Number] ASC);
GO
