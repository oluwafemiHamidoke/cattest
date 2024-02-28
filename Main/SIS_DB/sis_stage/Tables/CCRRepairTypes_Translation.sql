CREATE TABLE [sis_stage].[CCRRepairTypes_Translation](
	[CCRRepairTypes_ID] [int] NOT NULL,
	[Language_ID] [int] NOT NULL,
	[RepairType] [nvarchar](225) NOT NULL,
	[RepairTypeDescription] [nvarchar](225) NOT NULL,
 CONSTRAINT [PK_CCRRepairTypes_Translation] PRIMARY KEY CLUSTERED 
(
	[CCRRepairTypes_ID] ASC,
	[Language_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO