CREATE TABLE [sis].[InfoType] (
    [InfoType_ID] INT NOT NULL,
    [Is_Structured] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_InfoType] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC)
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'InfoType', @level2type = N'COLUMN', @level2name = N'InfoType_ID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'new table, https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'InfoType';
GO

