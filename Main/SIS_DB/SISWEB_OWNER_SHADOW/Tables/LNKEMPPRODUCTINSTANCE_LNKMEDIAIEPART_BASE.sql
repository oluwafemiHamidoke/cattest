CREATE TABLE [SISWEB_OWNER_SHADOW].[LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE](
    [LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_ID] INT  IDENTITY(1,1) NOT NULL,
    [EMPPRODUCTINSTANCE_ID] INT NULL,
    [SNP] [varchar](60) NULL,
    [LANGUAGEINDICATOR] [varchar](2) NOT NULL,
    [NUMBER] [varchar](60) NOT NULL,
    [MEDIANUMBER] [varchar](8) NOT NULL,
    [PARENTAGE] [numeric](1, 0) NOT NULL,
    [PARENTPRODUCTSTRUCTUREID] [char](8) NOT NULL,
    [PRODUCTSTRUCTUREID] [char](8) NOT NULL,
    [IESYSTEMCONTROLNUMBER] [varchar](12) NOT NULL,
    [INFOTYPEID] [smallint] NULL,
    [PARTNUMBER] [varchar](40) NULL,
    [PARTNAME] [nvarchar](128) NULL,
    [PARTMODIFIER] [nvarchar](512) NULL,
    [PARTCAPTION] [nvarchar](2048) NULL,
    [ISTOPLEVEL] [bit] NULL,
    [ORGCODE] VARCHAR (12) NULL,
    CONSTRAINT [PK_LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART] PRIMARY KEY CLUSTERED ([LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_ID] ASC)
    ) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_SNP_LANGUAGEINDICATOR_PRODUCTSTRUCTUREID_NUMBER] ON [SISWEB_OWNER_SHADOW].[LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE]
(
    [SNP] ASC,
    [LANGUAGEINDICATOR] ASC,
    [PRODUCTSTRUCTUREID] ASC,
    [NUMBER] ASC
)

GO
CREATE NONCLUSTERED INDEX [NCX_LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_SNP_LANGUAGEINDICATOR_PARENTPRODUCTSTRUCTUREID_NUMBER] ON [SISWEB_OWNER_SHADOW].[LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE]
(
	[SNP] ASC,
	[LANGUAGEINDICATOR] ASC,
	[PARENTPRODUCTSTRUCTUREID] ASC,
	[NUMBER] ASC
)
INCLUDE([MEDIANUMBER],[PARENTAGE],[PRODUCTSTRUCTUREID],[IESYSTEMCONTROLNUMBER],[INFOTYPEID],[PARTNUMBER],[PARTNAME],[PARTMODIFIER],[PARTCAPTION],[ISTOPLEVEL],[ORGCODE]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IDX_EMPPRODUCTINSTANCE_ID] ON [SISWEB_OWNER_SHADOW].[LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE]
(
	EMPPRODUCTINSTANCE_ID ASC
)
INCLUDE([MEDIANUMBER]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKEMPPRODUCTINSTANCE_LNKMEDIAIEPART_BASE';

