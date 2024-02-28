CREATE TABLE [SISWEB_OWNER].[PART_SUPERSESSIONCHAIN](
	[PART_SUPERSESSIONCHAIN_ID] [int] NOT NULL,
	[PARTNUMBER] [varchar](40) NOT NULL,
	[CHAIN] [varchar](4000) NOT NULL,
 	CONSTRAINT [PK_PART_SUPERSESSIONCHAIN_PARTNUMBER] PRIMARY KEY CLUSTERED ([PART_SUPERSESSIONCHAIN_ID] ASC)
  )
GO
CREATE NONCLUSTERED INDEX [IX_NCL_PART_SUPERSESSIONCHAIN_PARTNUMBER_CHAIN] ON [SISWEB_OWNER].[PART_SUPERSESSIONCHAIN]
(
	[PARTNUMBER] ASC,
	[CHAIN] ASC
);
