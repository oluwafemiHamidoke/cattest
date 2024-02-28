CREATE TABLE [sis_stage].[CCRUpdateTypes](
	[CCRUpdateTypes_ID] [int] IDENTITY(1,1) NOT NULL,
	[UpdateTypeIndicator] [char](1) NOT NULL,
	[SequenceNumber] [int] NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCRUpdateTypes] PRIMARY KEY CLUSTERED 
(
	[CCRUpdateTypes_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO