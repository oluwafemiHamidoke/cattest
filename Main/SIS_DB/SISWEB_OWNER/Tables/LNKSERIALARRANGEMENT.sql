﻿CREATE TABLE [SISWEB_OWNER].[LNKSERIALARRANGEMENT] (
    [SERIALNUMBER]          VARCHAR (8)   NOT NULL,
    [ARRANGEMENTPARTNUMBER] VARCHAR (20)  NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6) NULL,
    CONSTRAINT [LNKSERIALARRANGEMENT_PK_LNKSERIALARRANGEMENT] PRIMARY KEY CLUSTERED ([SERIALNUMBER] ASC, [ARRANGEMENTPARTNUMBER] ASC)
);


GO

