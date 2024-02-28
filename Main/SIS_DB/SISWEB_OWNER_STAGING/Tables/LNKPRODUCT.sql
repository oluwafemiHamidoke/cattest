﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKPRODUCT](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PRODUCTCODE] [varchar](4) NOT NULL,
	[SEQUENCENUMBER] [smallint] NOT NULL,
	[SALESMODELNO] [varchar](21) NOT NULL,
	[SNP] [varchar](10) NOT NULL,
	[SALESMODELSEQNO] [smallint] NOT NULL,
	[STATUSINDICATOR] [varchar](1) NOT NULL,
	[CCRINDICATOR] [varchar](1) NOT NULL,
	[FREQUENCY] [varchar](1) NULL,
	[SHIPPEDDATE] [datetime2](0) NULL,
	[CLASSICPARTINDICATOR] [varchar](1) NOT NULL,
    CONSTRAINT [LNKPRODUCT_PK_LNKPRODUCT] PRIMARY KEY CLUSTERED ([PRODUCTCODE] ASC, [SEQUENCENUMBER] ASC, [SALESMODELNO] ASC, [SNP] ASC)
);
GO

CREATE NONCLUSTERED INDEX IX_LNKPRODUCT_PRODUCTCODE 
ON SISWEB_OWNER_STAGING.LNKPRODUCT (PRODUCTCODE ASC); 
GO

CREATE NONCLUSTERED INDEX IX_LNKPRODUCT_SHIPPEDDATE 
ON SISWEB_OWNER_STAGING.LNKPRODUCT (SHIPPEDDATE ASC); 
GO

CREATE NONCLUSTERED INDEX IX_LNKPRODUCT_SNP 
ON SISWEB_OWNER_STAGING.LNKPRODUCT (SNP ASC); 
GO