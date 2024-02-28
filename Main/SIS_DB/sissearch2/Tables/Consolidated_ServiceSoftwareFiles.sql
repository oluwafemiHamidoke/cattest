CREATE TABLE [sissearch2].[Consolidated_ServiceSoftwareFiles](
	[ID] [varchar](100) NOT NULL,
	[ServiceFile_ID] [int] NULL,
	[InfoType] varchar(10) NOT NULL,
	[MediaNumber] [varchar](7) NOT NULL,
	[IEPart] [nvarchar](700) NULL,
	[Updated_Date] [datetime2](7) NOT NULL,
	[IsMedia] [bit] NOT NULL,
	[Profile] [varchar](max) NULL,
	[Insert_Date] [datetime2](7) NULL,
	[PubDate] [datetime2](7) NULL,
	[MediaOrigin] [varchar](4) NOT NULL,
	[CPINumber] [varchar](max) NULL,
 CONSTRAINT [PK_Consolidated_ServiceSoftwareFiles] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

alter table [sissearch2].[Consolidated_ServiceSoftwareFiles] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);
GO