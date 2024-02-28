CREATE TABLE [sis].[IIB_Language] (
    [Language_ID]                         INT          NOT NULL,
    [Lookup_Supported_Locale]             VARCHAR (10) NOT NULL,
    [CountryStateList_Supported_Locale]   VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_IIB_Language] PRIMARY KEY CLUSTERED ([Language_ID] ASC, [Lookup_Supported_Locale] ASC, [CountryStateList_Supported_Locale] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_IIB_Language_Language_ID] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID])
);
