CREATE TABLE [etl_stage].[Media] (
	[Media_Number]              [varchar](50)   NOT NULL,
	[Source]                    [varchar](50)   NULL,
	[Safety_Document_Indicator] [bit]           NULL,
	[PIPPS_Number]              [varchar](50)   NULL,
	[Last_Updated_Date]              [datetime]      NOT NULL
);