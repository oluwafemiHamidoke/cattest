CREATE TABLE [etl_stage].[IEPart_Effectivity] (
	[Base_English_Control_Number]   [varchar](50)           NOT NULL,
    [Serial_Number_Prefix]          [varchar](3)            NOT NULL,
    [Start_Serial_Number]           [int]                   NOT NULL,
    [End_Serial_Number]             [int]                   NOT NULL,
    [SerialNumberPrefix_Type]       [char](1) DEFAULT ('N') NOT NULL,
    [Last_Updated_Date]             [datetime]              NULL
);