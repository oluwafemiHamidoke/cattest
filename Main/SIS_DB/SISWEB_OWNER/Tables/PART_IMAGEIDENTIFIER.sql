CREATE TABLE [SISWEB_OWNER].[PART_IMAGEIDENTIFIER]
(
	[PART_NUMBER] [varchar](50) NOT NULL,
	[CM_NUMBER] [varchar](50) NOT NULL,
	[SEQUENCE_NUMBER] [int] NOT NULL,
	CONSTRAINT [PK_PART_IMAGEIDENTIFIER] PRIMARY KEY CLUSTERED ([PART_NUMBER] ASC, [CM_NUMBER] ASC, [SEQUENCE_NUMBER] ASC)
);