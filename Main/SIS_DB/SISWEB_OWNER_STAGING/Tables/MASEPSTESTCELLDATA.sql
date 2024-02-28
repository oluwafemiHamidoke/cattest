﻿CREATE TABLE [SISWEB_OWNER_STAGING].[MASEPSTESTCELLDATA] (
    [SERIALNUMBER]     VARCHAR (8)   NOT NULL,
    [SALESMODEL]       VARCHAR (10)  NULL,
    [VEHICLEMODEL]     VARCHAR (5)   NULL,
    [BUILT]            DATETIME2 (0) NULL,
    [PLANT]            VARCHAR (2)   NULL,
    [TESTDATE]         DATETIME2 (0) NULL,
    [SHIPPED]          DATETIME2 (0) NULL,
    [TESTED]           VARCHAR (2)   NULL,
    [TESTNUMBER]       VARCHAR (2)   NULL,
    [CELLNUMBER]       VARCHAR (2)   NULL,
    [COMBUSTION]       VARCHAR (2)   NULL,
    [LASTMODIFIEDDATE] VARCHAR (50)  NULL,
    CONSTRAINT [MASEPSTESTCELLDATA_PK_MASEPSTESTCELLDATA] PRIMARY KEY CLUSTERED ([SERIALNUMBER] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[MASEPSTESTCELLDATA] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO
