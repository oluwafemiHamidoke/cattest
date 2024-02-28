CREATE TABLE [sis].[Kit_Category_Relation]
	 ( 		
	   [Kit_ID]							[int]				NOT NULL
	 , [KitCategory_ID]					[int]				NOT NULL   
	 , [Type]						    [char](1)		    NOT NULL DEFAULT 'P'--Primary / Secondary
	 , CONSTRAINT [PK_Kit_Category_Relation]        PRIMARY KEY CLUSTERED 
     (
	   [Kit_ID] ASC, [KitCategory_ID] ASC , [Type] ASC
     )
	 , CONSTRAINT [FK_Kit_Category_Relation_Kit] FOREIGN KEY 
	 (
	   [Kit_ID]
	 ) REFERENCES [sis].[Kit] ([Kit_ID])
	 , CONSTRAINT [FK_Kit_Category_Relation_KitCategory] FOREIGN KEY 
	 (
	   [KitCategory_ID]
	 ) REFERENCES [sis].[KitCategory] ([KitCategory_ID])
	 );
GO

Create nonclustered index IX_Kit_Category_Relation_KitCategory_ID on sis.Kit_Category_Relation ([KitCategory_ID])  ;