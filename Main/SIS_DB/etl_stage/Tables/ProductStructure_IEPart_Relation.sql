CREATE TABLE [etl_stage].[ProductStructure_IEPart_Relation] (
    [Media_Number]                  [varchar](50)   NOT NULL,
    [Base_English_Control_Number]   [varchar](50)   NOT NULL,
    [ProductStructure_ID]           [int]           NOT NULL,
    [Serial_Number_Prefix]          [varchar](3)    NOT NULL,
    [Start_Serial_Number]           [int]           NOT NULL,
    [End_Serial_Number]             [int]           NOT NULL,
	[Last_Updated_Date]             [datetime]      NOT NULL
);