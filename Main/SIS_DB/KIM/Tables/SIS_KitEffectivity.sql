﻿CREATE TABLE [KIM].[SIS_KitEffectivity](
	[KITNUMBER] [nvarchar](7) NULL,
	[SALESMODEL] [nvarchar](10) NULL,
	[PRODUCTFAMILY] [nvarchar](250) NULL,
	[MACHINEPREFIX] [nvarchar](3) NULL,
	[MACHINESNBEGIN] [int] NULL,
	[MACHINESNEND] [int] NULL,
	[ENGINEPREFIX] [nvarchar](3) NULL,
	[ENGINESNBEGIN] [int] NULL,
	[ENGINESNEND] [int] NULL,
	[TQCONVERTORPREFIX] [nvarchar](3) NULL,
	[TQCONVERTORSNBEGIN] [int] NULL,
	[TQCONVERTORSNEND] [int] NULL,
	[TRANSMISSIONARRANGEMENT] [nvarchar](7) NULL,
	[TOP_ITEM_NO] [nvarchar](7) NULL,
	[UPDATEDON] [datetime] NULL
);