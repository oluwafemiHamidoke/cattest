CREATE TABLE [sp_staging].[PDT](
	[PART_NUMBER] 		[varchar](255) 	NULL,
	[PART_NAME] 		[nvarchar](500) NULL,
	[CHANGE_LEVEL] 		[varchar](255) 	NULL,
	[CLASS_NAME] 		[varchar](255) 	NULL,
	[CLASS_ID] 			int 			NULL,
	[PATH] 				[varchar](max) 	NULL,
	[ATTRIBUTE_NAME] 	[varchar](255) 	NULL,
	[ATTRIBUTE_ID] 		int 			NULL,
	[ATTRIBUTE_VALUE] 	[varchar](max) 	NULL,
	[GROUP_ID_PATH] 	[varchar](255) 	NULL,
	[REFRESHED_TS] 		[datetime2](7) 	NULL
)