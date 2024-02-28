CREATE TABLE [SISWEB_OWNER].[EMPSALESMODEL_BASE] (
    [EMPSALESMODEL_ID]      INT                NOT NULL,
    [EMPPRODUCTFAMILY_ID]   INT                NOT NULL,
    [NUMBER]                VARCHAR (60)       NOT NULL,
    [NAME]                  VARCHAR (60),
    [ALTERNATEMODEL]        VARCHAR (60),
    [ISCATMODEL]            BIT,
    [SERVICEABLE]           BIT,
    [MODEL]                 VARCHAR (60),
    [SNP]                   VARCHAR (60),
    [VERSION]               VARCHAR (13),
    [STATE]                 VARCHAR (15),
    [CURRENTSTATE]          VARCHAR (15),
    [LASTMODIFIEDDATE]      DATETIME2 (6),
    CONSTRAINT [PK_EMPSALESMODEL] PRIMARY KEY CLUSTERED ([EMPSALESMODEL_ID] ASC),
    CONSTRAINT [UQ_EMPSALESMODEL] UNIQUE(NUMBER)
);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'EMPSALESMODEL_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'EMPSALESMODEL_BASE';

GO
CREATE NONCLUSTERED INDEX IX_EMPSALESMODEL_NUMBER_EMPPRODUCTFAMILY_ID
    ON SISWEB_OWNER.EMPSALESMODEL_BASE (NUMBER ASC, EMPPRODUCTFAMILY_ID ASC);
GO