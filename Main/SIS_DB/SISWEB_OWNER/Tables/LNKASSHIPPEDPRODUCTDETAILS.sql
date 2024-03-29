﻿CREATE TABLE [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] (
    [SERIALNUMBER]           VARCHAR (8)      NOT NULL,
    [PARTSEQUENCENUMBER]     NUMERIC (10)     NOT NULL,
    [PARTNUMBER]             VARCHAR (20)     NOT NULL,
    [PARTNAME]               VARCHAR (512)    NOT NULL,
    [PARENTPARTNUMBER]       VARCHAR (20)     NULL,
    [ATTACHMENTSERIALNUMBER] VARCHAR (20)     NULL,
    [SOURCELOCATION]         VARCHAR (1)      NOT NULL,
    [EMDPROCESSEDDATE]       DATETIME2 (0)    NOT NULL,
    [PARTTYPE]               VARCHAR (25)     NULL,
    [ID]                     NUMERIC (38, 10) NOT NULL,
    [LASTMODIFIEDDATE]       DATETIME2 (6)    NULL,
    [isValidSerialNumber]    BIT              NULL,
    [isValidPartNumber]      BIT              NULL,
    [ID_Int]                 BIGINT           NULL,
    [ParentID]               BIGINT           NULL,
    [SNP]                    CHAR (3)         NULL,
    [SNR]                    INT              NULL,
    [PARTORDER]              NUMERIC (10)     NULL,
    [PARTLEVEL]              NUMERIC (1)      NULL,
    [PARENTAGE]              NUMERIC (38, 10) NULL,
    CONSTRAINT [LNKASSHIPPEDPRODUCTDETAILS_LNKASSHIPPEDPRODUCTDETAILS_PK] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [LNKASSHIPPEDPRODUCTDETAILS_PARENTPARTNUMBER_NC]
    ON [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]([SERIALNUMBER] ASC, [PARTNUMBER] ASC, [PARENTPARTNUMBER] ASC);

