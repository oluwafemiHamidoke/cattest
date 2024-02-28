CREATE TABLE [admin].[User_Contact] (
    [User_ID]                   INT           NOT NULL,
    [Contact_ID]                INT           NOT NULL,
    [User_Contact]              VARCHAR (150) NOT NULL,
    [Contact_Type]              CHAR (1)      CONSTRAINT [DF_User_Contact_Contact_Type] DEFAULT ('E') NOT NULL,
    [Created_By]                NVARCHAR(50) DEFAULT '' NOT NULL,
    [Created_On]                DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    [Last_Modified_By]          NVARCHAR(50) DEFAULT '' NOT NULL,
    [Last_Modified_On]          DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    CONSTRAINT [PK_User_Contact] PRIMARY KEY CLUSTERED ([Contact_ID] ASC),
    CONSTRAINT [FK_User_Contact_User] FOREIGN KEY ([User_ID]) REFERENCES [admin].[User_Details] ([User_ID])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Can be E for Email or P for Phone', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'User_Contact', @level2type = N'COLUMN', @level2name = N'Contact_Type';

