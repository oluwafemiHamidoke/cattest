CREATE TABLE [sis].[KitBillOfMaterial]
     (  
	   [Kit_ID]							[int]				NOT NULL
	 , [KitComponent_ID]				[int]				NOT NULL
	 , [Quantity]						[int] 
	 , [Serviceability_Indicator]		[varchar](1)
	 , CONSTRAINT [PK_KitBillOfMaterial]        PRIMARY KEY CLUSTERED
     (
	   [Kit_ID] ASC, [KitComponent_ID] ASC 
     )
	 , CONSTRAINT [FK_KitBillOfMaterial_Kit] FOREIGN KEY 
	 (
	   [Kit_ID]
	 ) REFERENCES [sis].[Kit] ([Kit_ID])
	 , CONSTRAINT [FK_KitBillOfMaterial_KitComponent] FOREIGN KEY 
	 (
	   [KitComponent_ID]
	 ) REFERENCES [sis].[KitComponent] ([KitComponent_ID])
     );
GO
