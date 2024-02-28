CREATE TABLE [sis_stage].[MIDCodeDetails](
	[MIDCodeDetails_ID]     [int] IDENTITY(1,1) NOT NULL,
	[MIDCode]               [int]               NOT NULL,
	[MIDType]               [varchar](10)       NOT NULL,
	[MIDDescription]        [nvarchar](200)     NOT NULL,
	CONSTRAINT [PK_MIDCodeDetails_MIDCodeDetails_ID] PRIMARY KEY CLUSTERED ([MIDCodeDetails_ID] ASC)
	)
