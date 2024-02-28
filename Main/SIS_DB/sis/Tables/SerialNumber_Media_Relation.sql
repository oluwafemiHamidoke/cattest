CREATE TABLE [sis].[SerialNumber_Media_Relation] (
    [SerialNumber_ID]    INT      NOT NULL,
    [Media_ID]           INT      NOT NULL,
    [Arrangement_Number] CHAR (8) NOT NULL,
    CONSTRAINT [PK_SerialNumber_Media_Relation] PRIMARY KEY CLUSTERED ([SerialNumber_ID] ASC, [Media_ID] ASC),
    CONSTRAINT [FK_SerialNumber_Media_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_SerialNumber_Media_Relation_SerialNumber] FOREIGN KEY ([SerialNumber_ID]) REFERENCES [sis].[SerialNumber] ([SerialNumber_ID])
);
GO
CREATE NONCLUSTERED INDEX [SerialNumber_Media_Relation_Media_ID]
ON [sis].[SerialNumber_Media_Relation] ([Media_ID])


