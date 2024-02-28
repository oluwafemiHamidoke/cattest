CREATE TABLE [sis_stage].[IE] (
    [IE_ID]                 INT          NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [UQ_IE] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_IE_IESystemControlNumber_IE_ID]
    ON [sis_stage].[IE]([IESystemControlNumber] ASC, [IE_ID] ASC);

