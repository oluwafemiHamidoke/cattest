CREATE TABLE [sis_stage].[Part_Translation] (
    [Part_ID]     INT           NOT NULL,
    [Language_ID] INT           NOT NULL,
    [Part_Name]   NVARCHAR (150) NULL,
    CONSTRAINT [PK_Part_GroupPart_Translation] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Language_ID] ASC)
);