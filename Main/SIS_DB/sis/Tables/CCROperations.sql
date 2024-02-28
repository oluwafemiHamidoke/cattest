CREATE TABLE [sis].[CCROperations](
	[Operation_ID] [int] NOT NULL,
	[Segment_ID] [int] NOT NULL,
	[Operation] [varchar](5) NOT NULL,
	[OperationNumber] [varchar](5) NOT NULL,
	[ComponentCode] [varchar](4) NOT NULL,
	[JobCode] [varchar](3) NOT NULL,
	[ModifierCode] [varchar](3) NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCROperations] PRIMARY KEY CLUSTERED 
(
	[Operation_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [sis].[CCROperations]  WITH CHECK ADD  CONSTRAINT [FK_CCROperations_Segment_ID] FOREIGN KEY([Segment_ID])
REFERENCES [sis].[CCRSegments] ([Segment_ID])
GO

ALTER TABLE [sis].[CCROperations] CHECK CONSTRAINT [FK_CCROperations_Segment_ID]
GO