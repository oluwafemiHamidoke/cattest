CREATE TABLE [sis].[CIDCodeDetails](
	[CIDCodeDetails_ID]     [int]               NOT NULL,
	[CIDCode]               [varchar](20)       NOT NULL,
	[CIDType]               [varchar](100)      NOT NULL,
	[CIDDescription]        [nvarchar](200)     NOT NULL,
    PRIMARY KEY CLUSTERED ( [CIDCodeDetails_ID] ASC)
    WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
