CREATE TABLE [sis].[MIDCodeDetails](
	[MIDCodeDetails_ID]     [int]               NOT NULL,
	[MIDCode]               [int]               NOT NULL,
	[MIDType]               [varchar](10)       NOT NULL,
	[MIDDescription]        [nvarchar](200)     NOT NULL,
    PRIMARY KEY CLUSTERED ( [MIDCodeDetails_ID] ASC )
    WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
