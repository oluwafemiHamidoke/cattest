CREATE TABLE [sis_stage].[RepairDescriptions_Translation](
	[RepairDescriptions_ID] [int] NOT NULL,
	[Language_ID] [int] NOT NULL,
	[RepairDescription] [nvarchar](288) NOT NULL,
 CONSTRAINT [PK_RepairDescriptions_Translation] PRIMARY KEY CLUSTERED 
(
	[RepairDescriptions_ID] ASC,
	[Language_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO