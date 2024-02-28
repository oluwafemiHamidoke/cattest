CREATE TABLE [sp_staging].[ATTRIBUTE](
	[ID] 					[int] 			NOT NULL,
	[NAME] 					[nvarchar](255) NULL,
	[TYPE_ID] 				[int] 			NULL,
	[FORMAT_ID] 			[int] 			NULL,
	[FORMAT_VALUE] 			[varchar](max) 	NULL,
	[FORMAT_METRIC] 		[varchar](255) 	NULL,
	[FORMAT_NON_METRIC]		[varchar](255) 	NULL,
	[MINIMUM_METRIC] 		[float] 		NULL,
	[MAXIMUM_METRIC] 		[float] 		NULL,
	[MINIMUM_NON_METRIC] 	[float] 		NULL,
	[MAXIMUM_NON_METRIC] 	[float] 		NULL,
	[UNIT_METRIC] 			[varchar](50) 	NULL,
	[DESC] 					[nvarchar](255) NULL,
	[UNIT_NON_METRIC] 		[varchar](50) 	NULL,
	[REFRESHED_TS] 			[datetime2](7) 	NULL
)