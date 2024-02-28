CREATE TABLE [sp_staging].[CLASS](
	[ID] 			[int] 			NOT NULL,
	[GROUP_ID] 		[int] 			NOT NULL,
	[NAME] 			[nvarchar](255) NULL,
	[CLASS_TYPE] 	[int] 			NULL,
	[IS_PENDING] 	[bit] 			NULL,
	[REFRESHED_TS] 	[datetime2](7) 	NULL
)