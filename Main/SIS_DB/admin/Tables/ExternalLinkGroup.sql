CREATE TABLE [admin].[ExternalLinkGroup]
(
	[ExternalLinkGroup_ID]	INT Identity(1,1)          NOT NULL,
	[FileLocation]			NVARCHAR(500),
	CONSTRAINT [PK_ExternalLinkGroup] PRIMARY KEY CLUSTERED ([ExternalLinkGroup_ID] ASC)
)
