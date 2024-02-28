CREATE TABLE [sis_stage].[IELevel_Translation](
	[IELevel_ID] [Int] NOT NULL,
	[Language_ID] [Int] NOT NULL,
	[Description] [Nvarchar](3072) NOT NULL,
 CONSTRAINT [PK_IELevel_Translation] PRIMARY KEY CLUSTERED 
(
	[IELevel_ID] ASC,
	[Language_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
;