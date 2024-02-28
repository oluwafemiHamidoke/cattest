CREATE TABLE [admin].[User_AccessProfile_Relation] (
    [User_ID]                   INT NOT NULL,
    [Profile_ID]                INT NOT NULL,
    [Group_ID]                  INT DEFAULT 43 NOT NULL,
    [Created_By]                NVARCHAR(50) DEFAULT '' NOT NULL,
    [Created_On]                DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    [Last_Modified_By]          NVARCHAR(50) DEFAULT '' NOT NULL,
    [Last_Modified_On]          DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    CONSTRAINT [PK_User_AccessProfile_Relation] PRIMARY KEY CLUSTERED ([User_ID] ASC, [Profile_ID] ASC, [Group_ID] ASC),
    CONSTRAINT [FK_User_AccessProfile_Relation_AccessProfile] FOREIGN KEY ([Profile_ID]) REFERENCES [admin].[AccessProfile] ([Profile_ID]),
    CONSTRAINT [FK_User_AccessProfile_Relation_User] FOREIGN KEY ([User_ID]) REFERENCES [admin].[User_Details] ([User_ID]),
    CONSTRAINT [FK_User_AccessProfile_Relation_Group] FOREIGN KEY ([Group_ID]) REFERENCES [admin].[Group_Details] ([Group_ID])

);

