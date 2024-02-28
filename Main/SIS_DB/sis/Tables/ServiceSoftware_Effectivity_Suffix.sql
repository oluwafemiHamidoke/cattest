CREATE TABLE [sis].[ServiceSoftware_Effectivity_Suffix](
	[ServiceSoftware_Effectivity_ID] [int] NOT NULL,
	[Suffix] [varchar](4) NOT NULL,
	CONSTRAINT [PK_ServiceSoftware_Effectivity_Suffix] PRIMARY KEY CLUSTERED([ServiceSoftware_Effectivity_ID] ASC, [Suffix] ASC),
	CONSTRAINT [FK_ServiceSoftware_Effectivity_ID] FOREIGN KEY ([ServiceSoftware_Effectivity_ID]) REFERENCES [sis].[ServiceSoftware_Effectivity]
) 