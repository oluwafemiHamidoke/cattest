CREATE TABLE [SISWEB_OWNER_SHADOW].[EMPPRODUCTFAMILY_BASE] (
    [EMPPRODUCTFAMILY_ID]   INT    NOT NULL,
    [NAME]               VARCHAR (60),
    [NUMBER]             VARCHAR (15) NOT NULL,
    [VERSION]            VARCHAR (13),
    [STATE]              VARCHAR (15),
    [CURRENTSTATE]       VARCHAR (15),
    [LASTMODIFIEDDATE]   DATETIME2 (6),
    CONSTRAINT [PK_EMPPRODUCTFAMILY] PRIMARY KEY CLUSTERED ([EMPPRODUCTFAMILY_ID] ASC),
    CONSTRAINT [UQ_EMPPRODUCTFAMILY] UNIQUE(NUMBER)
);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'EMPPRODUCTFAMILY_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'EMPPRODUCTFAMILY_BASE';

GO
CREATE NONCLUSTERED INDEX IX_EMPPRODUCTFAMILY_NUMBER
    ON SISWEB_OWNER_SHADOW.EMPPRODUCTFAMILY_BASE (NUMBER ASC);
GO