CREATE TABLE [sis_stage].[CIDCodeDetails](
	[CIDCodeDetails_ID]     [int]           IDENTITY(1,1)   NOT NULL,
	[CIDCode]               [varchar](20)                   NOT NULL,
	[CIDType]               [varchar](100)                  NOT NULL,
	[CIDDescription]        [nvarchar](200)                 NOT NULL,
	CONSTRAINT [PK_CIDCodeDetails_CIDCodeDetails_ID] PRIMARY KEY CLUSTERED ([CIDCodeDetails_ID] ASC)
	)
