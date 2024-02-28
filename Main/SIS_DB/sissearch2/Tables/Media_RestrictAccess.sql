CREATE TABLE [sissearch2].[Media_RestrictAccess](
	[Media_Number] [varchar](15) NOT NULL,
	[RestrictionCode] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Media_Number] ASC
)
);