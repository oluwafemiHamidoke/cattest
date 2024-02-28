CREATE TABLE [sis].[ProductStructure_IEPart](
	[ProductStructure_ID] [int] NOT NULL,
	[IEPart_ID] [int] NOT NULL,
	[Media_ID] [int] NOT NULL,
	[Parentage] [tinyint] NOT NULL,
	[ParentProductStructure_ID] [int] NULL
) ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [IDX_ProductStructure_IEPart_ID] ON [sis].[ProductStructure_IEPart]
(
	[IEPart_ID] ASC,
	[Media_ID] ASC,
	[ProductStructure_ID] ASC,
	[ParentProductStructure_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ProductStructure_IEPart] ON [sis].[ProductStructure_IEPart]
(
	[IEPart_ID] ASC,
	[Media_ID] ASC
)
INCLUDE([Parentage],[ParentProductStructure_ID],[ProductStructure_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IE_Part_ID_MediaID_Parentage_ParentProductStructure_ID_ProductStructure_ID] ON [sis].[ProductStructure_IEPart]
(
	[IEPart_ID] ASC,
	[Media_ID] ASC,
	[Parentage] ASC,
	[ParentProductStructure_ID] ASC,
	[ProductStructure_ID] ASC
)
WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
