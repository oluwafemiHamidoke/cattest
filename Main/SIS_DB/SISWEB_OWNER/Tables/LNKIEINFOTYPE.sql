CREATE TABLE [SISWEB_OWNER].[LNKIEINFOTYPE]
	([IESYSTEMCONTROLNUMBER] VARCHAR(12) NOT NULL
	,[INFOTYPEID]            SMALLINT NOT NULL
	,[LASTMODIFIEDDATE]      DATETIME2(6) NULL
	,CONSTRAINT [PK_LNKIEINFOTYPE] PRIMARY KEY CLUSTERED([IESYSTEMCONTROLNUMBER] ASC,[INFOTYPEID] ASC));
GO

CREATE NONCLUSTERED INDEX [NCX_InfoTypeID] ON [SISWEB_OWNER].[LNKIEINFOTYPE] ([INFOTYPEID] ASC);
GO

EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'See https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4608/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SISWEB_OWNER'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'LNKIEINFOTYPE'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
