CREATE TABLE [etl_stage].[Part] (
    [Part_Number]       [varchar] (50)      NOT NULL,
    [Org_Code]          [varchar] (12)      NOT NULL,
    [Part_Name]         [NVARCHAR] (150)    NULL,
	[Language_Tag]      [varchar](50)       NOT NULL,
    [Last_Updated_Date] DATETIME            NULL
);