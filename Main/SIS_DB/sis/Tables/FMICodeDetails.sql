CREATE TABLE [sis].[FMICodeDetails](
	[FMICodeDetails_ID]     [int]             NOT NULL,
	[FMICode]               [int]             NOT NULL,
	[FMIType]               [varchar](100)    NOT NULL,
	[FMIDescription]        [nvarchar](200)   NOT NULL,
    PRIMARY KEY CLUSTERED ( [FMICodeDetails_ID] ASC )
    WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
