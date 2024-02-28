CREATE TABLE [admin].[User_Group_Relation] (
    [User_ID]          INT           NOT NULL,
    [Group_ID]         INT           NOT NULL,
    [Reason_ID]        INT           NULL,
    [Is_Active]        BIT           DEFAULT ((0)) NOT NULL,
    [Is_Admin]         BIT           DEFAULT ((0)) NOT NULL,
    [Created_By]       NVARCHAR (50) DEFAULT ('') NOT NULL,
    [Created_On]       DATETIME2 (1) DEFAULT (getutcdate()) NOT NULL,
    [Last_Modified_By] NVARCHAR (50) DEFAULT ('') NOT NULL,
    [Last_Modified_On] DATETIME2 (1) DEFAULT (getutcdate()) NOT NULL,
    [Note]             NVARCHAR (60) NULL,
    CONSTRAINT [PK_User_Group_Relation] PRIMARY KEY CLUSTERED ([User_ID] ASC, [Group_ID] ASC),
    CONSTRAINT [FK_User_Group_Relation_Group] FOREIGN KEY ([Group_ID]) REFERENCES [admin].[Group_Details] ([Group_ID]),
    CONSTRAINT [FK_User_Group_Relation_Reason] FOREIGN KEY ([Reason_ID]) REFERENCES [admin].[Reason] ([Reason_ID]),
    CONSTRAINT [FK_User_Group_Relation_User] FOREIGN KEY ([User_ID]) REFERENCES [admin].[User_Details] ([User_ID])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Many to many relationship table between Users and Groups.
For each pair of User and Group, stores the Role of the User in the Group: the role can be Admin (A) or Member (M)', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'User_Group_Relation';


GO
CREATE NONCLUSTERED INDEX [IX_User_Group_Relation_AdminActive]
    ON [admin].[User_Group_Relation]([Is_Admin] ASC, [Is_Active] ASC);

