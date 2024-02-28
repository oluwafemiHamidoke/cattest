CREATE TABLE [sis_stage].[CCRUpdatesIE_Relation](
	[Update_ID] [int] NOT NULL,
	[Operation_ID] [int] NOT NULL,
	[UpdateTypeIndicator] [char](1) NOT NULL,
	[IE_ID] [int] NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCRUPDATES] PRIMARY KEY CLUSTERED 
(
	[Update_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO