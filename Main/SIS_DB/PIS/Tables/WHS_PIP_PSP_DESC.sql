CREATE TABLE [PIS].[WHS_PIP_PSP_DESC](
	[PIP_PSP_NO] [varchar](7) NOT NULL,
	[PIP_DESC] [varchar](40) NOT NULL,
	[SVC_LTR_DT] [date] NOT NULL,
	[TERM_DT] [date] NOT NULL,
	[ACTV_DT] [date] NOT NULL,
	[ENT_DT] [date] NOT NULL,
	[SFTY_NON_SFTY_CD] [varchar](2) NOT NULL,
	[BDGT_DOL] [numeric](9, 0) NOT NULL,
	[TOT_SER_NO_CT] [numeric](7, 0) NOT NULL,
	[CO_ID] [varchar](20) NOT NULL,
	[RPR_LBR_HR] [numeric](7, 2) NOT NULL,
	[PUB_IND] [varchar](1) NOT NULL,
	[MFR_CD] [varchar](4) NOT NULL,
	[LAST_UPDT_TS] [datetime2](6) NOT NULL,
	[LAST_UPDT_CUPID] [varchar](10) NOT NULL,
	[CRTE_TS] [datetime2](6) NOT NULL,
	[CRTE_CUPID] [varchar](10) NOT NULL
) ON [PRIMARY]
GO