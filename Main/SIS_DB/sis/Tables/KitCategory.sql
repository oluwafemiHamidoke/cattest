CREATE TABLE [sis].[KitCategory]
     (	
	   [KitCategory_ID]							[int]IDENTITY(1,1) 			NOT NULL
	 , [Name]						            [nvarchar](1000)			NOT NULL
     , [Parent_ID]                              [int]
     , CONSTRAINT [PK_KitCategory]              PRIMARY KEY CLUSTERED 
     (
	   [KitCategory_ID] ASC
     )     
     , CONSTRAINT [FK_KitCategory_Parent_ID] FOREIGN KEY 
	 (
	   [Parent_ID]
	 ) REFERENCES [sis].[KitCategory] ([KitCategory_ID])
     );
GO

