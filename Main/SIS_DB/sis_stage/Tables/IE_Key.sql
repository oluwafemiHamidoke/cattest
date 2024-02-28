CREATE TABLE [sis_stage].[IE_Key] (
    [IE_ID]                 INT          IDENTITY (1, 1) NOT NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [UQ_IE_Key] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC)
);

