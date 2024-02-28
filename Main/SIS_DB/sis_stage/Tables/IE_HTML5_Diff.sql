CREATE TABLE [sis_stage].[IE_HTML5_Diff] (
    [Operation]             VARCHAR (50) NOT NULL,
    [IE_ID]                 INT          NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [UQ_IE_HTML5_Diff] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC) WITH (FILLFACTOR = 100)
);

