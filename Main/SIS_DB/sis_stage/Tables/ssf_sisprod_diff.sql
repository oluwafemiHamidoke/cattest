CREATE TABLE [sis_stage].[ssf_sisprod_diff](
	[Serial_Number_Prefix] [varchar](3) NULL,
	[Start_Serial_Number] [int] NULL,
	[End_Serial_Number] [int] NULL,
	[Application_Code] [int] NULL,
	[Part_Number] [varchar](50) NULL,
	[OPERATION] [varchar](8) NOT NULL,
	[ServiceFile_ID] [int] NULL
) ON [PRIMARY]
GO

