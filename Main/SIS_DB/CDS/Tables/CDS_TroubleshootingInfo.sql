CREATE TABLE [CDS].[CDS_TroubleshootingInfo](
	[Prefix] [varchar](20) NOT NULL,
	[BeginRange] [int] NOT NULL,
	[EndRange] [int] NOT NULL,
	[CodeID] [int] NOT NULL,
	[MID] [int] NULL,
	[CIDCode] [varchar](20) NULL,
	[CIDType] [varchar](100) NULL,
	[FMICode] [int] NULL,
	[FMIType] [varchar](100) NULL,
	[IEControlNumber] [varchar](50) NULL,
	[IsCovered] [bit] NULL,
	[UpdatedTime] [datetime] NULL,
	[CodeIsDeleted] [bit] NULL
) ON [PRIMARY]
