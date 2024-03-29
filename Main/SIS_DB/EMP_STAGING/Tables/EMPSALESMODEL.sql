CREATE TABLE [EMP_STAGING].[EMPSALESMODEL] (
    [EMPSALESMODEL_ID]      INT          NOT NULL IDENTITY (1, 1),
    [EMPPRODUCTFAMILY_ID]   INT          NOT NULL,
    [NUMBER]                VARCHAR (60) NOT NULL,
    [NAME]                  VARCHAR (60),
    [ALTERNATEMODEL]        VARCHAR (60),
    [ISCATMODEL]            BIT,
    [SERVICEABLE]           BIT,
    [MODEL]                 VARCHAR (60),
    [SNP]                   VARCHAR (60),
    [VERSION]               VARCHAR (13),
    [STATE]                 VARCHAR (15),
    [LASTMODIFIEDDATE]      DATETIME2 (6),
    CONSTRAINT [PK_EMPSALESMODEL] PRIMARY KEY CLUSTERED ([EMPSALESMODEL_ID] ASC),
    CONSTRAINT [UQ_EMPSALESMODEL] UNIQUE(NUMBER)
);

GO
ALTER TABLE [EMP_STAGING].[EMPSALESMODEL] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

GO
CREATE NONCLUSTERED INDEX IX_EMPSALESMODEL_NUMBER_EMPPRODUCTFAMILY_ID
    ON EMP_STAGING.EMPSALESMODEL (NUMBER ASC, EMPPRODUCTFAMILY_ID ASC);
GO