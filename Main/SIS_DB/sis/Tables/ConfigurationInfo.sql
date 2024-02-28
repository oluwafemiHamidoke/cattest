CREATE TABLE [sis].[ConfigurationInfo](
	[Configuration_ID]      [int]           NOT NULL,
	[Name]                  [nvarchar](100) NOT NULL,
	[UpdatedBy]             [varchar](30)   NOT NULL,
	[UpdatedTime]           [datetime]      NOT NULL,
	[CreatedBy]             [varchar](30)   NULL,
	[CreatedTime]           [datetime]      NULL,
	[IsDeleted]             [bit]           NOT NULL,
	[Abbreviation]          [nvarchar](100) NULL,
    CONSTRAINT [PK_ConfigurationInfo_Configuration_ID] PRIMARY KEY CLUSTERED ([Configuration_ID] ASC)
)