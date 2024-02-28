CREATE TABLE [sis].[Part_ImageIdentifier]
(
  [Part_ID]			[INT] NOT NULL, 
  [CM_Number]		[VARCHAR](50)	NOT NULL,
  [Sequence_Number] [INT] NOT NULL,
  CONSTRAINT [PK_Part_ImageIdentifier] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [CM_Number] ASC, [Sequence_Number] ASC),
  CONSTRAINT [FK_Part_ImageIdentifier_Part]  FOREIGN KEY ( [Part_ID] ) REFERENCES [sis].[Part] ([Part_ID])
)
GO