CREATE TABLE [sis].[KitType]
     (	
	   [KitType_ID]							[int]IDENTITY(1,1) 			NOT NULL
	 , [Name]						[nvarchar](100)				NOT NULL
     , CONSTRAINT [PK_KitType]                 PRIMARY KEY CLUSTERED 
     (
	   [KitType_ID] ASC
     )
     );
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_KitType]
    ON [sis].[KitType]([Name] ASC);
GO
