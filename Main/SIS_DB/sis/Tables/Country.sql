CREATE TABLE [sis].[Country] (
    [Country_ID]   INT      NOT NULL,
    [Country_Code] CHAR (2) NOT NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([Country_ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Country_Country_Code]
    ON [sis].[Country]([Country_Code] ASC);

