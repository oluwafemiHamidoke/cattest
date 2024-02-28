CREATE TABLE [etl_stage].[Media_Effectivity] (
	[Media_Number]              [varchar](50)   NOT NULL,
	[Serial_Number_Prefix]      [varchar](3)    NOT NULL,
    [Start_Serial_Number]       [int]           NOT NULL,
    [End_Serial_Number]         [int]           NOT NULL,
    [Last_Updated_Date]         [datetime]      NULL
);