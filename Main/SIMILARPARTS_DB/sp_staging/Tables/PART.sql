CREATE TABLE [sp_staging].[PART](
	[ID] 			[int] 			NOT NULL,
	[CLASS_ID] 		[int] 			NOT NULL,
	[PART_NUMBER] 	[varchar](255) 	NULL,
	[NAME] 			[nvarchar](255) NULL,
	[IS_PENDING] 	[tinyint] 		NULL,
	[REFRESHED_TS] 	[datetime2](7) 	NOT NULL
)