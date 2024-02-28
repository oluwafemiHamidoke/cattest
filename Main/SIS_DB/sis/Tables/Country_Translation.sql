CREATE TABLE [sis].[Country_Translation] (
    [Country_ID]          INT            NOT NULL,
    [Language_ID]         INT            NOT NULL,
    [Country_Description] NVARCHAR (150) NOT NULL,
    CONSTRAINT [PK_Country_Translation] PRIMARY KEY CLUSTERED ([Country_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_Country_Translation_Country] FOREIGN KEY ([Country_ID]) REFERENCES [sis].[Country] ([Country_ID]),
    CONSTRAINT [FK_Country_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID])
);

