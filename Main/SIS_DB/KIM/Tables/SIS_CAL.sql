CREATE TABLE [KIM].[SIS_CAL](
	[PART_NUMBER] [nvarchar](4000),
	[IMAGE_NAME] [nvarchar](100),
	[CM_NUMBER] [nvarchar](50),
	[C_NUMBER] [nvarchar](50),
	[VERSION] [nvarchar](5)
)

GO
CREATE CLUSTERED INDEX [CI_SIS_CAL]
    ON [KIM].[SIS_CAL]([PART_NUMBER] ASC);

