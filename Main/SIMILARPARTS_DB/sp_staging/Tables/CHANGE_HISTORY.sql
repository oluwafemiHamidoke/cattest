CREATE TABLE [sp_staging].[CHANGE_HISTORY](
	[ID] 					[int] 			NOT NULL,
	[CLASS_ID] 				[int] 			NOT NULL,
	[ADMIN_ID] 				[int] 			NULL,
	[USER_ID] 				[int] 			NOT NULL,
	[PART_ID] 				[int] 			NULL,
	[PART_NAME] 			[nvarchar](255) NULL,
	[PART_NUMBER] 			[varchar](255) 	NULL,
	[MODIFIED_AT] 			[datetime2](7) 	NULL,
	[CHECKED_AT] 			[datetime2](7) 	NULL,
	[ACTION] 				[int] 			NULL,
	[SME_APPROVAL_STATUS]	[int] 			NULL,
	[ENTRY_METHOD] 			[int] 			NOT NULL,
	[PART_SOURCE_ID] 		[int] 			NULL,
	[REASONS] 				[int] 			NULL,
	[SME_COMMENTS] 			[nvarchar](max) NULL,
	[SOURCE_ALIAS_PART_ID] 	[nvarchar](50) 	NULL,
	[REFRESHED_TS] 			[datetime2](7) 	NULL
)