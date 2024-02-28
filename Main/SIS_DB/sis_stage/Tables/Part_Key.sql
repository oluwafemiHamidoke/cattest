CREATE TABLE [sis_stage].[Part_Key] (
    [Part_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Part_Number] VARCHAR (50) NOT NULL,
    [Org_Code]    VARCHAR (12) NOT NULL DEFAULT 'CAT',
    CONSTRAINT [PK_Part_Key] PRIMARY KEY CLUSTERED ([Part_ID] ASC)
);