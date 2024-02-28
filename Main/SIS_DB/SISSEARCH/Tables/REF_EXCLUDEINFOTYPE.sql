CREATE TABLE [SISSEARCH].[REF_EXCLUDEINFOTYPE] (
    [InfoTypeID] SMALLINT NOT NULL,
    [Media]      BIT      NULL,
	[Search2_Status] BIT NULL,
    [Selective_Exclude] BIT default 0 not NULL,
    PRIMARY KEY CLUSTERED ([InfoTypeID] ASC)
);

