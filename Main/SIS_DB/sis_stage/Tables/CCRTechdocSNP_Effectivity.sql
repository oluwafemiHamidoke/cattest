CREATE TABLE [sis_stage].[CCRTechdocSNP_Effectivity](
	[Update_ID] [numeric](10, 0) NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
 CONSTRAINT [PK_CCRTechdocSNP_Effectivity] PRIMARY KEY CLUSTERED 
(
	[Update_ID] ASC,
	[SerialNumberPrefix_ID] ASC,
	[SerialNumberRange_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO