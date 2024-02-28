CREATE TABLE [sis].[CCRVirtualIE_Effectivity](
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[Operation_ID] [int] NOT NULL,
	[IEPart_ID] [int] NOT NULL,
 CONSTRAINT [PK_CCRVirtualIE_Effectivity] PRIMARY KEY CLUSTERED 
(
	[SerialNumberPrefix_ID] ASC,
	[Operation_ID] ASC,
	[IEPart_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO