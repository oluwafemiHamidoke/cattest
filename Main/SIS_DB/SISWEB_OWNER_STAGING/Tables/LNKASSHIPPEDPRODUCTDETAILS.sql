CREATE TABLE [SISWEB_OWNER_STAGING].[LNKASSHIPPEDPRODUCTDETAILS] (
    [SERIALNUMBER]           VARCHAR (8)      NOT NULL,
    [PARTSEQUENCENUMBER]     NUMERIC (10)     NOT NULL,
    [PARTNUMBER]             VARCHAR (20)     NOT NULL,
    [PARTNAME]               VARCHAR (512)    NOT NULL,
    [PARENTPARTNUMBER]       VARCHAR (20)     NULL,
    [ATTACHMENTSERIALNUMBER] VARCHAR (20)     NULL,
    [SOURCELOCATION]         VARCHAR (1)      NOT NULL,
    [EMDPROCESSEDDATE]       DATETIME2 (0)    NOT NULL,
    [ID]                     NUMERIC (38, 10) NOT NULL,
    [PARTORDER]              NUMERIC (10)     NULL,
    [PARTLEVEL]              NUMERIC (1)      NULL,
    [PARENTAGE]              NUMERIC (38, 10) NULL,
    [LASTMODIFIEDDATE]       DATETIME2 (6)    NULL,
    CONSTRAINT [PK_LNKASSHIPPEDPRODUCTDETAILS] PRIMARY KEY NONCLUSTERED ([ID] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKASSHIPPEDPRODUCTDETAILS] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);




GO

GO
CREATE CLUSTERED INDEX [IX_LNKASSHIPPEDPRODUCTDETAILS_SERIALNUMBER]
    ON [SISWEB_OWNER_STAGING].[LNKASSHIPPEDPRODUCTDETAILS]([SERIALNUMBER] ASC);

