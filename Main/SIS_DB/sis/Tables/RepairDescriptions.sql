CREATE TABLE [sis].[RepairDescriptions](
	[RepairDescriptions_ID] [int] NOT NULL,
	[RepairCode] [varchar](4) NOT NULL,
	[RepairType] [char](1) NOT NULL,
 CONSTRAINT [PK_RepairDescriptions] PRIMARY KEY CLUSTERED 
(
	[RepairDescriptions_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO