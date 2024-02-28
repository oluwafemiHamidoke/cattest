CREATE TABLE [EMP_STAGING].[EMPPRODUCTFAMILY] (
    [EMPPRODUCTFAMILY_ID] INT           NOT NULL  IDENTITY (1, 1),
    [NAME]                VARCHAR (60),
    [NUMBER]              VARCHAR (15)  NOT NULL,
    [VERSION]             VARCHAR (13),
    [STATE]               VARCHAR (15),
    [LASTMODIFIEDDATE]   DATETIME2 (6),
    CONSTRAINT [PK_EMPPRODUCTFAMILY] PRIMARY KEY CLUSTERED ([EMPPRODUCTFAMILY_ID] ASC),
    CONSTRAINT [UQ_EMPPRODUCTFAMILY] UNIQUE(NUMBER)
);

GO
ALTER TABLE [EMP_STAGING].[EMPPRODUCTFAMILY] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

GO
CREATE NONCLUSTERED INDEX IX_EMPPRODUCTFAMILY_NUMBER
    ON EMP_STAGING.EMPPRODUCTFAMILY (NUMBER ASC);
GO
