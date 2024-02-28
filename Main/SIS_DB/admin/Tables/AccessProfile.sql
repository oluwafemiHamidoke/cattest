CREATE TABLE [admin].[AccessProfile] (
    [Profile_ID]          INT Identity(1,1)          NOT NULL,
    [Profile_Description] VARCHAR (50) NOT NULL, 
    [Priority]            INT DEFAULT 10 NOT NULL,
    [ExternalLinkGroup_ID]  INT NULL,
    [SuperAdminAccessRequired] BIT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_AccessProfile] PRIMARY KEY CLUSTERED ([Profile_ID] ASC),
    CONSTRAINT [FK_AccessProfile_ExternalLinkGroup] FOREIGN KEY ([ExternalLinkGroup_ID]) REFERENCES [admin].[ExternalLinkGroup] ([ExternalLinkGroup_ID])
);

