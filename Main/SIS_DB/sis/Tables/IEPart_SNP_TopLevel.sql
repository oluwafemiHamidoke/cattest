CREATE TABLE [sis].[IEPart_SNP_TopLevel](
	[ProductStructure_ID] [int] NOT NULL,
	[isTopLevel] [int] NOT NULL,
	[Media_Number] [varchar](50) NOT NULL,
	[IESystemControlNumber] [varchar](12) NULL,
	[Sequence_Number] [int] NOT NULL,
	[Modifier] [varchar](250) NULL,
	[Caption] [varchar](4000) NULL,
	[Serial_Number_Prefix] [varchar](3) NOT NULL,
	[Part_ID] [int] NOT NULL
) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IDX_IEPart_SNP_TopLevel_ProductStructure_ID] ON [sis].[IEPart_SNP_TopLevel]
(
	[ProductStructure_ID] ASC,
	[Media_Number] ASC,
	[IESystemControlNumber] ASC
)
INCLUDE([isTopLevel],[Modifier],[Caption],[Part_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IDX_IEPart_SNP_TopLevel_SNP_Language_ID] ON [sis].[IEPart_SNP_TopLevel]
(
	[Serial_Number_Prefix] ASC
)
INCLUDE([ProductStructure_ID],[isTopLevel],[Media_Number],[IESystemControlNumber],[Modifier],[Caption],[Part_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IDX_Media_Number_IESystemControlNumber_SNP] ON [sis].[IEPart_SNP_TopLevel]
(
	[Media_Number] ASC,
	[IESystemControlNumber] ASC,
	[Serial_Number_Prefix] ASC
)
INCLUDE([ProductStructure_ID],[isTopLevel],[Modifier],[Caption],[Part_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IDX_Part_ID] ON [sis].[IEPart_SNP_TopLevel]
(
	[Part_ID] ASC
)
INCLUDE([ProductStructure_ID],[isTopLevel],[Media_Number],[IESystemControlNumber],[Modifier],[Caption],[Serial_Number_Prefix]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO