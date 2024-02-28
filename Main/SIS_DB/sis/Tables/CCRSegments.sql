CREATE TABLE [sis].[CCRSegments](
	[Segment_ID] [int] NOT NULL,
	[CCRMedia_ID] [int] NOT NULL,
	[Segment] [varchar](5) NOT NULL,
	[ComponentCode] [varchar](4) NOT NULL,
	[JobCode] [varchar](3) NOT NULL,
	[ModifierCode] [varchar](3) NULL,
	[Hours] [numeric](6, 1) NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_MASCCRSEGMENTS] PRIMARY KEY CLUSTERED 
(
	[Segment_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
