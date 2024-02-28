CREATE TABLE [sis].[Kit_ImageIdentifier]
(
  [Kit_ID]			[int] NOT NULL, 
  [CM_Number]		[varchar](50)	NOT NULL,
  CONSTRAINT [PK_Kit_ImageIdentifier] PRIMARY KEY CLUSTERED ([Kit_ID] ASC, [CM_Number] ASC),
  CONSTRAINT [FK_Kit_ImageIdentifier_Kit]  FOREIGN KEY ( [Kit_ID] ) REFERENCES [sis].[Kit] ([Kit_ID])
)
GO