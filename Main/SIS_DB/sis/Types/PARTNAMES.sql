﻿CREATE TYPE [sis].[PARTNAMES] AS TABLE (
    [PARTNAME] VARCHAR (200) NOT NULL,
    PRIMARY KEY NONCLUSTERED ([PARTNAME] ASC));
