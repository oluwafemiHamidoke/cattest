CREATE TABLE [sis_stage].[Part] (
    [Part_ID]     INT          NULL,
    [Part_Number] VARCHAR (50) NOT NULL,
    [Org_Code]    VARCHAR (12) NOT NULL DEFAULT 'CAT',
    CONSTRAINT [PK_Part] PRIMARY KEY CLUSTERED ([Part_Number] ASC, [Org_Code] ASC)
);

GO
CREATE INDEX [IX_Part_Part_ID_B924D] ON [sis_stage].[Part] ([Part_ID])

GO
CREATE NONCLUSTERED INDEX IDX_Part_OrgCode ON [sis_stage].[Part] ([Org_Code]) INCLUDE ([Part_ID]);