﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKATTACHMENTDESCRIPTION]
(
	[ATTACHMENTTYPE]            VARCHAR(6)      NOT NULL,
    [LANGUAGEINDICATOR]         VARCHAR(2)      NOT NULL,
    [ATTACHMENTDESCRIPTION]     NVARCHAR(150)   NOT NULL,
    [LASTMODIFIEDDATE]          DATETIME2(6)    NULL,
    CONSTRAINT [PK_LNKATTACHMENTDESCRIPTION] PRIMARY KEY ([ATTACHMENTTYPE] ASC, [LANGUAGEINDICATOR] ASC)
);