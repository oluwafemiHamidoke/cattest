CREATE TABLE [sis].[Part_Translation] (
    [Part_ID]     INT           NOT NULL,
    [Language_ID] INT           NOT NULL,
    [Part_Name]   NVARCHAR (150) NULL,
    CONSTRAINT [PK_Part_GroupPart_Translation] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_Part_GroupPart_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_Part_Translation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);

GO
CREATE NONCLUSTERED INDEX XI_Part_Translation_Language_ID_Part_Name
ON [sis].[Part_Translation] 
(
    [Language_ID] ASC,
    [Part_Name]
)