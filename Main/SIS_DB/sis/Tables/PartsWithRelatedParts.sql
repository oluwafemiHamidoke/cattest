CREATE TABLE [sis].[PartsWithRelatedParts](
	[Media_Number] [varchar](50) NOT NULL,
	[Serial_Number_Prefix] [varchar](3) NOT NULL,
	[IE_System_Control_Number] [varchar](12) NULL,
	[Media_Origin] [varchar](8) NULL,
	[Part_Number] [varchar](50) NOT NULL,
	[Part_ID] [int] NULL,
	[Related_Part_Number] [varchar](50) NOT NULL,
	[Related_Part_ID] [int] NULL,
	[Type_Indicator] [varchar](10) NOT NULL,
	[Parent_Product_Structure_ID] [int] NULL,
	[Product_Structure_Description] [nvarchar](250) NULL,
	[Product_Structure_ID] [int] NOT NULL,
	[Start_Serial_Number] [int] NULL,
	[End_Serial_Number] [int] NULL,
	[Relation_Type] [varchar](50) NULL
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_PartsWithRelatedParts_IESCN] ON [sis].[PartsWithRelatedParts]
(
	[IE_System_Control_Number] ASC,
	[Start_Serial_Number] ASC,
	[End_Serial_Number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_PartsWithRelatedParts_SNP] ON [sis].[PartsWithRelatedParts]
(
	[Serial_Number_Prefix] ASC,
	[Media_Origin] ASC,
	[Start_Serial_Number] ASC,
	[End_Serial_Number] ASC
)
INCLUDE([Media_Number],[IE_System_Control_Number],[Part_Number],[Related_Part_Number],[Type_Indicator],[Parent_Product_Structure_ID],[Product_Structure_Description],[Product_Structure_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO