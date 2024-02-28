CREATE TABLE [sis].[Media_Effectivity] (
    [Media_ID]              INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL,
    CONSTRAINT [PK_Media_Effectivity] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC),
    CONSTRAINT [FK_Media_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_Media_Relation_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_Media_Relation_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
);
GO
Create nonclustered index IX_Media_Effectivity_SerialNumberPrefix_ID on sis.Media_Effectivity (SerialNumberPrefix_ID) include (Media_ID)  ;
GO
Create nonclustered index IX_Media_Effectivity_SerialNumberRange_ID on sis.Media_Effectivity (SerialNumberRange_ID)  ;
GO
