CREATE TABLE [sis_stage].[CCRMedia](
	[CCRMedia_ID] [int] NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[RepairTypeIndicator] [char](1) NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCRMedia] PRIMARY KEY CLUSTERED 
(
	[CCRMedia_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO