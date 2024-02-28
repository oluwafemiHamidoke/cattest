CREATE TABLE [CDS].[CDS_ConfigurationInfo](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[UpdatedBy] [varchar](30) NOT NULL,
	[UpdatedTime] [datetime] NOT NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreatedTime] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[Abbreviation] [nvarchar](100) NULL
) ON [PRIMARY]