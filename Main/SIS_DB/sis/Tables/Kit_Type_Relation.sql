
CREATE TABLE [sis].[Kit_Type_Relation]
	 ( 		
	   [Kit_ID]						[int]				NOT NULL
	 , [KitType_ID]					[int]				NOT NULL   
	 , CONSTRAINT [PK_Kit_Type_Relation]        PRIMARY KEY CLUSTERED 
     (
	   [Kit_ID] ASC, [KitType_ID] ASC 
     )
	 , CONSTRAINT [FK_Kit_Type_Relation_Kit] FOREIGN KEY 
	 (
	   [Kit_ID]
	 ) REFERENCES [sis].[Kit] ([Kit_ID])
	 , CONSTRAINT [FK_Kit_Type_Relation_KitType] FOREIGN KEY 
	 (
	   [KitType_ID]
	 ) REFERENCES [sis].[KitType] ([KitType_ID])
	 );
GO

create nonclustered index IX_Kit_type_relation_KitType_Id_ on sis.Kit_Type_Relation (KitType_ID) include (Kit_ID);

GO