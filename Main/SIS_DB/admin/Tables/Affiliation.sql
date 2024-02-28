CREATE TABLE [admin].[Affiliation] (
    [Affiliation_ID]          INT Identity(1,1)          NOT NULL,
    [Affiliation_Code]        CHAR (3)     NOT NULL,
    [Affiliation_Description] VARCHAR (60) NULL,
    [Affiliation_Class]       VARCHAR (9)  NULL,
    [Allow_Profile_Multi_Select]      BIT          NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_Affiliation] PRIMARY KEY CLUSTERED ([Affiliation_ID] ASC)
);



