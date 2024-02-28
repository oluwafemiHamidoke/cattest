
CREATE TABLE [sis].[Kit_ParentPart_Relation]
	 ( 		
	   [Kit_ID]							[int]				NOT NULL
	 , [ParentPart_ID]					[int]				NOT NULL   
	 , [SetType]						[nvarchar](30)				
	 , CONSTRAINT [PK_Kit_ParentPart_Relation]        PRIMARY KEY CLUSTERED 
     (
	   [Kit_ID] ASC, [ParentPart_ID] ASC 
     )
	 , CONSTRAINT [FK_Kit_ParentPart_Relation_Kit] FOREIGN KEY 
	 (
	   [Kit_ID]
	 ) REFERENCES [sis].[Kit] ([Kit_ID])
	 , CONSTRAINT [FK_Kit_ParentPart_Relation_ParentPart] FOREIGN KEY 
	 (
	   [ParentPart_ID]
	 ) REFERENCES [sis].[Part] ([Part_ID])
	 );
GO

Create nonclustered index IX_Kit_ParentPart_Relation_ParentPart_ID on sis.Kit_ParentPart_Relation ([ParentPart_ID])  ;