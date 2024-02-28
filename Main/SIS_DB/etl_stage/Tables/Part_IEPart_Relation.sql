CREATE TABLE [etl_stage].[Part_IEPart_Relation] (
	[Base_English_Control_Number]   [varchar](50)       NOT NULL,
    [Consist_Part_Number]           [varchar](50)       NOT NULL,
    [Consist_Org_Code]              [varchar](12)       NOT NULL,
    [Consist_Part_Name]             [varchar](50)       NULL,
	[Language_Tag]                  [varchar](50)       NOT NULL,
    [Sequence_Number]               [int]               NOT NULL,
    [Reference_Number]              [varchar](50)       NULL,
    [Graphic_Number]                [varchar](50)       NULL,
    [Quantity]                      [varchar](50)       NULL,
    [Serviceability_Indicator]      [varchar](1)        NULL,
    [Parentage]                     [smallint]          NULL,
    [CCR_Indicator]                 [bit]               NULL,
    [Consist_Part_Modifier]         [nvarchar] (1000)   NULL,
	[Consist_Part_Note]             [nvarchar](50)      NULL,
    [Last_Updated_Date]             [datetime]          NULL
);