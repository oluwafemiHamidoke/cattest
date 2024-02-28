CREATE TABLE [sp_staging].[PART_ATTRIBUTES](
	[PART_ID] 		[int] 			NOT NULL,
	[ATTRIBUTE_ID] 	[int] 			NOT NULL,
	[VALUE] 		[nvarchar](max) NULL,
	[REFRESHED_TS] 	[datetime2](7) 	NULL
)