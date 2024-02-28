CREATE TABLE [sis_stage].[IE_HTML5_Key] (
    [IE_ID]                 INT          IDENTITY (1, 1) NOT NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [UQ_IE_HTML5_Key] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC) WITH (FILLFACTOR = 100)
);

