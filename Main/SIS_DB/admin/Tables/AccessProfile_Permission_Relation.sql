CREATE TABLE [admin].[AccessProfile_Permission_Relation] (
    [Profile_ID]           INT NOT NULL,
    [PermissionType_ID]    INT NOT NULL,
    [Include_Exclude]      BIT NOT NULL,
    [Permission_Detail_ID] INT NOT NULL,
    CONSTRAINT [PK_AccessProfile_Permission_Relation] PRIMARY KEY CLUSTERED ([PermissionType_ID] ASC, [Profile_ID] ASC, [Permission_Detail_ID] ASC),
    CONSTRAINT [FK_AccessProfile_Permission_Relation_AccessProfile] FOREIGN KEY ([Profile_ID]) REFERENCES [admin].[AccessProfile] ([Profile_ID]),
    CONSTRAINT [FK_AccessProfile_Permission_Relation_Permission] FOREIGN KEY ([PermissionType_ID]) REFERENCES [admin].[Permission] ([PermissionType_ID])
);
GO

CREATE INDEX AccessProfile_Permission_Relation_PermissionType_ID ON admin.AccessProfile_Permission_Relation (PermissionType_ID, Include_Exclude, Permission_Detail_ID)
GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Three way relationship table between Profiles, PermissionTypes and PermissionDetails. The value 0 in Permission_Detail_ID means access to all the elements of the PermissionType (eg. all SNPs). The value -1 means access to no element of The PermissionType (eg. no Product)', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'AccessProfile_Permission_Relation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK to the [admin].[AccessProfile] table', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'AccessProfile_Permission_Relation', @level2type = N'COLUMN', @level2name = N'Profile_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK to table [admin].[Permission], the type of Permission Included or Excluded', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'AccessProfile_Permission_Relation', @level2type = N'COLUMN', @level2name = N'PermissionType_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The object of the Permission. All=0, None=-1. All other values are FK to the corresponding PermissionType lookup table. If PermissionType is SNP, this is the ID of the SNP, if the PermissionType is InfoType this is the ID of the InfoType', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'AccessProfile_Permission_Relation', @level2type = N'COLUMN', @level2name = N'Permission_Detail_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Boolean value: Include=1, Exclude=0', @level0type = N'SCHEMA', @level0name = N'admin', @level1type = N'TABLE', @level1name = N'AccessProfile_Permission_Relation', @level2type = N'COLUMN', @level2name = N'Include_Exclude';

