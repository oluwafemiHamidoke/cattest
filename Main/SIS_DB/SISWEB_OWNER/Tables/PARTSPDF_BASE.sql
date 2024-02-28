CREATE TABLE [SISWEB_OWNER].[PARTSPDF_BASE] (
    [PARTSPDF_ID]           INT                    NOT NULL,
    [MEDIANUMBER]           VARCHAR (8)            NOT NULL,
    [PDFNUMBER]             VARCHAR (60)           NOT NULL,
    [PDFFILENAME]           VARCHAR (60)           NOT NULL,
    [PDFTYPE]               VARCHAR (30)           NOT NULL,
    [REVISION]              INT                    NOT NULL,
    [LANGUAGEINDICATOR]     VARCHAR (2)            NOT NULL,
    [FILEPATH]              VARCHAR (512)          NOT NULL,
    [FILESIZE]              INT                    NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6)              NULL,
    CONSTRAINT [PK_PARTSPDF] PRIMARY KEY CLUSTERED ([PARTSPDF_ID] ASC)
);

GO
CREATE NONCLUSTERED INDEX idx_PARTSPDF_PARTSPDF_ID_LANGUAGE ON SISWEB_OWNER.PARTSPDF_BASE (PARTSPDF_ID ASC, LANGUAGEINDICATOR ASC);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'PARTSPDF_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'PARTSPDF_BASE';

