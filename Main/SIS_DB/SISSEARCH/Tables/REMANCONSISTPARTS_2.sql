﻿CREATE TABLE [SISSEARCH].[REMANCONSISTPARTS_2] (
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [REMANCONSISTPART]      VARCHAR (MAX) NULL,
    [INSERTDATE]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);