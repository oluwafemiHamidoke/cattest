CREATE TABLE [etl_stage].[IEPart] (
    [Part_Number]                 [varchar] (50) NOT NULL,
    [Org_Code]                    [varchar] (12) NOT NULL,
    [Base_English_Control_Number] [varchar] (50) NOT NULL,
    [Part]                        [varchar] (10) NULL,
    [Of_Parts]                    [varchar] (10) NULL,
    [Publish_Date]                [DATETIME]     NOT NULL,
    [IE_Control_Number]           [varchar] (20) NULL ,
    [Last_Updated_Date]           [DATETIME]     NULL
);