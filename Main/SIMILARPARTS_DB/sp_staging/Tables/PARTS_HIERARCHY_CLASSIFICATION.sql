CREATE TABLE [sp_staging].[PARTS_HIERARCHY_CLASSIFICATION](
	[CLASS_NAME] 				[varchar](500) 	NULL,
	[CLASS_IDENTIFIER] 			[varchar](50) 	NULL,
	[PARENT_IDENTIFIER] 		[bigint] 		NULL,
	[GROUP_IDENTIFIER] 			[varchar](50) 	NULL,
	[ATTRIBUTE_IDENTIFIER] 		[varchar](50) 	NULL,
	[PATH_VALUE] 				[varchar](max) 	NULL,
	[PARENT_NAME] 				[varchar](max) 	NULL,
	[HIERARCHY_LEVEL_INDICATOR] [bigint] 		NULL,
	[REFRESHED_TS] 				[datetime2](7) 	NULL
)