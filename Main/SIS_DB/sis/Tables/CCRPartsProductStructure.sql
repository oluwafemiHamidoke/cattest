CREATE TABLE [sis].[CCRPartsProductStructure](
	[Media_Number] [varchar](50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[Serial_Number_Prefix] [varchar](3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[IESystemControlNumber] [varchar](12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[Part_Number] [varchar](50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[Part_ID] [int] NOT NULL,
	[PARENTPRODUCTSTRUCTUREID] [int] NULL,
	[PRODUCTSTRUCTUREID] [int] NOT NULL,
	[Start_Serial_Number] [int] NOT NULL,
	[End_Serial_Number] [int] NOT NULL,
	[CCR_Indicator] [varchar](1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) 
GO

CREATE NONCLUSTERED INDEX [idx_CCRPartsProductStructure] ON [sis].[CCRPartsProductStructure]
(
	[Serial_Number_Prefix] ASC,
	[CCR_Indicator] ASC,
	[Start_Serial_Number] ASC,
	[End_Serial_Number] ASC
)
INCLUDE([Media_Number],[IESystemControlNumber],[Part_Number],[Part_ID],[PARENTPRODUCTSTRUCTUREID],[PRODUCTSTRUCTUREID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

