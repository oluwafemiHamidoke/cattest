CREATE TABLE [SISWEB_OWNER_STAGING].[UPDATEDSERIALNUMBER](
	SERIALNUMBER	VARCHAR(20)NOT NULL
)
GO
CREATE INDEX IDX_UPDATEDSERIALNUMBER_SN ON [SISWEB_OWNER_STAGING].[UPDATEDSERIALNUMBER] (SERIALNUMBER)
GO