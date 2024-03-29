CREATE TABLE [sis].[IELevel] (
	[IELevel_ID] INT NOT NULL
	,[IE_ID] INT NOT NULL
	,[LevelSequenceNumber] SMALLINT NOT NULL
	,[LevelID] SMALLINT NOT NULL
	,[ParentID] [Int] NULL
	,CONSTRAINT [PK_IELevel] PRIMARY KEY CLUSTERED ([IELevel_ID] ASC) WITH (
		STATISTICS_NORECOMPUTE = OFF
		,IGNORE_DUP_KEY = OFF
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
		) ON [PRIMARY]
	) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IX_IELevel_IE_ID] ON [sis].[IELevel] ([IE_ID] ASC) INCLUDE (
	[LevelSequenceNumber]
	,[LevelID]
	,[ParentID]
	)
GO