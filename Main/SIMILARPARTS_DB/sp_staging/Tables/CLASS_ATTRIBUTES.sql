CREATE TABLE [sp_staging].[CLASS_ATTRIBUTES](
	[CLASS_ID] 				[int] 			NOT NULL,
	[ATTRIBUTE_ID] 			[int] 			NOT NULL,
	[ATTRIBUTE_LEVEL_ID] 	[int] 			NOT NULL,
	[ATTRIBUTE_ORDER] 		[int] 			NULL,
	[ATTRIBUTE_REQUIRED]	[bit] 			NULL,
	[REFRESHED_TS] 			[datetime2](7) 	NULL
)