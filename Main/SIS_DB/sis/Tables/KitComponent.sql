CREATE TABLE [sis].[KitComponent]
     (	
	   [KitComponent_ID]				[int]IDENTITY(1,1) 	NOT NULL   
	 , [Number]			[varchar](50)		NOT NULL   -- [COMPONENT_NUMBER] [nvarchar](7)
	 , [Name]				[nvarchar](30)		NOT NULL   -- [PARTNAME] [nvarchar](30)
     , CONSTRAINT [PK_KitComponent]        PRIMARY KEY CLUSTERED 
     (
	   [KitComponent_ID] ASC
     )
     );
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_KitComponent]
    ON [sis].[KitComponent]([Number] ASC);
GO
