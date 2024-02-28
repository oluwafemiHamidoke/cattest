CREATE TABLE [sis_stage].[ServiceSoftware_Effectivity_Suffix](
	[ServiceSoftware_Effectivity_ID] [int] NOT NULL,
	[Suffix] [varchar](4) NOT NULL,
	CONSTRAINT [PK_ServiceSoftware_Effectivity_Suffix] PRIMARY KEY CLUSTERED([ServiceSoftware_Effectivity_ID] ASC, [Suffix] ASC)
) 