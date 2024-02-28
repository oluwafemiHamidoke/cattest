-- =============================================
-- Author:      Obieda Ananbeh
-- Create Date: 05182023
-- Description: temp table to Get Ecm Files name and Rid
-- =============================================

CREATE TABLE [sis_stage].[ssf_Output_SSF_EcmGetOrGenerateFileRid](
	[fileName] [nvarchar](max) NULL,
	[isExists] [bit] NULL,
	[fileRid] [int] NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


