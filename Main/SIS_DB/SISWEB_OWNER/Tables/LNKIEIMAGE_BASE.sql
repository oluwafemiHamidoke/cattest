﻿CREATE TABLE [SISWEB_OWNER].[LNKIEIMAGE_BASE] (
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)  NOT NULL,
    [GRAPHICCONTROLNUMBER]  VARCHAR (60)  NOT NULL,
    [GRAPHICSEQUENCENUMBER] SMALLINT      NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6) NULL,
    CONSTRAINT [LNKIEIMAGE_PK_LNKIEIMAGE] PRIMARY KEY CLUSTERED ([IESYSTEMCONTROLNUMBER] ASC, [GRAPHICCONTROLNUMBER] ASC, [GRAPHICSEQUENCENUMBER] ASC) WITH (FILLFACTOR = 100)
);






GO
CREATE NONCLUSTERED INDEX [IX_LNKIEIMAGE_GRAPHICCONTROLNUMBER]
    ON [SISWEB_OWNER].[LNKIEIMAGE_BASE]([GRAPHICCONTROLNUMBER] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'LNKIEIMAGE_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'LNKIEIMAGE_BASE';

