CREATE TABLE [sis_stage].[FMICodeDetails](
	[FMICodeDetails_ID]     [int]   IDENTITY(1,1)   NOT NULL,
	[FMICode]               [int]                   NOT NULL,
	[FMIType]               [varchar](100)          NOT NULL,
	[FMIDescription]        [nvarchar](200)         NOT NULL,
	CONSTRAINT [PK_FMICodeDetails_FMICodeDetails_ID] PRIMARY KEY CLUSTERED ([FMICodeDetails_ID] ASC)
	)
