CREATE TABLE [sis_stage].[ServiceSoftware_Effectivity](
	[ServiceSoftware_Effectivity_ID] [int] IDENTITY(1,1) NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[Start_Serial_Number] [int] NOT NULL, 
	[End_Serial_Number] [int] NOT NULL, 
	[Application_ID] [int] NOT NULL,
	[Component_ID] [int] NOT NULL,
	[Location_Code] [int] NULL,
	[Part_Number] [varchar](50) NOT NULL,
    [Version] [varchar](3) NOT NULL,
	[Product_Link_Config] [varchar](50) NULL,
	CONSTRAINT [PK_ServiceSoftware_Effectivity] PRIMARY KEY CLUSTERED([ServiceSoftware_Effectivity_ID] ASC)
)  
