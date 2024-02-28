CREATE TABLE [etl_stage].[MediaSequence] (
    [Media_Number]              [varchar](50)   NOT NULL,
	[Section_Number]            [int]           NOT NULL,
    [Part_Number]               [varchar](50)  NOT NULL,
    [Org_Code]                  [varchar](12)   NOT NULL,
    [Sequence_Number]           [int]           NOT NULL,
    [InfoType]                  [int]           NOT NULL,
    [Serviceability_Indicator]  [varchar](1)    NULL,
	[Arrangement_Indicator]     [varchar](1)    NULL,
	[TypeChange_Indicator]      [varchar](1)    NULL,
	[NPR_Indicator]             [varchar](1)    NULL,
	[IESystemControlNumber]     [varchar](12)   NULL,
    [Publish_Date]              [datetime]      NOT NULL,
	[Last_Updated_Date]         [datetime]      NOT NULL
);