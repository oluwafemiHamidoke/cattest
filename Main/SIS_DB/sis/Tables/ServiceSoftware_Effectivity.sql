CREATE TABLE [sis].[ServiceSoftware_Effectivity](
	[ServiceSoftware_Effectivity_ID] [int] NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[Start_Serial_Number] [int] NOT NULL,
	[End_Serial_Number] [int] NOT NULL,
	[Application_ID] [int] NOT NULL,
	[Component_ID] [int] NOT NULL,
	[Location_Code] [int] NULL,
	[Part_Number] [varchar](50) NOT NULL,
    [Version] [varchar](3) NOT NULL,
	[Product_Link_Config] [varchar](50) NULL,
	CONSTRAINT [PK_ServiceSoftware_Effectivity] PRIMARY KEY CLUSTERED([ServiceSoftware_Effectivity_ID] ASC),
	CONSTRAINT FK_ServiceSoftware_Effectivity_SerialNumberPrefix FOREIGN KEY(SerialNumberPrefix_ID) REFERENCES sis.SerialNumberPrefix(SerialNumberPrefix_ID)
	) 
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
ON [sis].[ServiceSoftware_Effectivity]([SerialNumberPrefix_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_ServiceSoftware_Effectivity_Product_Link_Config]
ON [sis].[ServiceSoftware_Effectivity] ([Product_Link_Config])
