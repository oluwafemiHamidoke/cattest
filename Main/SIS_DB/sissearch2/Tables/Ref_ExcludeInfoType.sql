CREATE TABLE [sissearch2].[Ref_ExcludeInfoType](
	[InfoTypeID] [smallint] NOT NULL,
	[Media] [bit] NULL,
	[Search2_Status] [bit] NULL,
	[Selective_Exclude] [bit] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED 
(
	[InfoTypeID] ASC
)
)

