CREATE TABLE [etl_stage].[IEPart_Effective_Date] (
	[Media_Number]                  [varchar](50) NOT NULL,
	[Base_English_Control_Number]   [varchar](50) NOT NULL,
    [Serial_Number_Prefix]          [varchar] (3) NOT NULL,
    [Start_Serial_Number]           [int]         NOT NULL,
    [End_Serial_Number]             [int]         NOT NULL,
	[DayEffective]			        [datetime]    NOT NULL,
	[DayNotEffective]		        [datetime]    NULL,
    [Last_Updated_Date]             [datetime]    NULL
);