CREATE TABLE [sissearch2].[Ref_Selective_ExcludeInfoType](
	[InfoTypeID] [smallint] NOT NULL,
	[Excluded_Values] [varchar](2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[InfoTypeID] ASC,
	[Excluded_Values] ASC
)
);