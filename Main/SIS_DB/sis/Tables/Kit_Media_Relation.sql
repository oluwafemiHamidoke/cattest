CREATE TABLE [sis].[Kit_Media_Relation] (
    [Kit_ID]					INT        	NOT NULL,
    [Media_ID]                  INT         NOT NULL
    CONSTRAINT [PK_Kit_Media_Relation]      PRIMARY KEY CLUSTERED ([Kit_ID] ASC, [Media_ID] ASC),
    CONSTRAINT [FK_Kit_Media_Relation_Kit]  FOREIGN KEY ( [Kit_ID] ) REFERENCES [sis].[Kit] ([Kit_ID]),
    CONSTRAINT [FK_Kit_Media_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
);
GO
CREATE NONCLUSTERED INDEX [Kit_Media_Relation_Media_ID]
ON [sis].[Kit_Media_Relation] ([Media_ID])
