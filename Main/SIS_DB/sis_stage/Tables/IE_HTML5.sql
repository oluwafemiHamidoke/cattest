CREATE TABLE [sis_stage].[IE_HTML5] (
    [IE_ID]                 INT          NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [UQ_IE_HTML5] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC)
);






GO


