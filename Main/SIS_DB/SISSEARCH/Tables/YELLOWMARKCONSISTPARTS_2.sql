﻿CREATE TABLE [SISSEARCH].[YELLOWMARKCONSISTPARTS_2] (
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [YELLOWMARKCONSISTPART] VARCHAR (MAX) NULL,
    [INSERTDATE]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);