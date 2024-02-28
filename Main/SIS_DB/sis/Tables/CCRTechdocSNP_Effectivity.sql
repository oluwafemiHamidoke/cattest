CREATE TABLE [sis].[CCRTechdocSNP_Effectivity](
	[Update_ID] [numeric](10, 0) NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCRTechdocSNP_Effectivity] PRIMARY KEY CLUSTERED 
(
	[Update_ID] ASC,
	[SerialNumberPrefix_ID] ASC,
	[SerialNumberRange_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO