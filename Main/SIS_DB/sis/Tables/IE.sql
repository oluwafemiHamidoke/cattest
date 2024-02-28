﻿CREATE TABLE [sis].[IE] (
    [IE_ID]                 INT          NOT NULL,
    [IESystemControlNumber] VARCHAR (12) NOT NULL,
    CONSTRAINT [PK_IE] PRIMARY KEY CLUSTERED ([IE_ID] ASC),
    CONSTRAINT [UC_IESystemControlNumber] UNIQUE NONCLUSTERED ([IESystemControlNumber] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Information Element: new table, https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
