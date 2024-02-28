CREATE TABLE [etl_stage].[Media_Translation] (
	[Media_Number]      [nvarchar](50)      NOT NULL,
	[Language_Tag]      [varchar](50)       NOT NULL,
	[Title]             [nvarchar](4000)    NULL,
	[Published_Date]    [date]              NULL,
	[Revision_Number]   [int]               NULL,
	[Media_Origin]      [varchar](2)        NULL,
	[Last_Updated_Date] [datetime]          NULL
);