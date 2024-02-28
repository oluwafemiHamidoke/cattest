CREATE TABLE [admin].[Organization_Cleanup_Audit](
	[Organization_ID] [int] NOT NULL,
	[TopLevel_Organization_Code] [varchar](10) NOT NULL,
	[Organization_Code] [varchar](10) NOT NULL,
	[Organization_Name] [nvarchar](160) NOT NULL
) ON [PRIMARY]
GO