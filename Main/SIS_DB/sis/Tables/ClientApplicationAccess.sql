CREATE TABLE [sis].[ClientApplicationAccess] (
    [ApplicationClient_ID] VARCHAR (50)  NOT NULL,
    [ApplicationName]      VARCHAR (100) NOT NULL,
    [Access]               VARCHAR (20)  NOT NULL,
    [Profile_ID]           INT           NULL,
    [SASTokenExpiryInSec]  INT           NULL,
    CONSTRAINT [PK_ClientApplicationAccess] PRIMARY KEY CLUSTERED ([ApplicationClient_ID] ASC),
    CONSTRAINT [FK_ClientApplicationAccess_Profile] FOREIGN KEY ([Profile_ID]) REFERENCES [admin].[AccessProfile] ([Profile_ID])
);





