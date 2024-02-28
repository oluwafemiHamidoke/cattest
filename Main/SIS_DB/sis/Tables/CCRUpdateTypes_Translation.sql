CREATE TABLE [sis].[CCRUpdateTypes_Translation](
	[CCRUpdateTypes_ID] [int] NOT NULL,
	[Language_ID] INT NOT NULL,
	[UpdateTypeDescription] [nvarchar](225) NOT NULL,
 CONSTRAINT [PK_CCRUpdateTypes_Translation] PRIMARY KEY CLUSTERED 
(
	[CCRUpdateTypes_ID] ASC,
	[Language_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO