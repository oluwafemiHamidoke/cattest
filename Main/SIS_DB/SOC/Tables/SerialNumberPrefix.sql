CREATE TABLE [SOC].[SerialNumberPrefix] (
    [SerialNumberPrefix_ID] INT         IDENTITY (1, 1) NOT NULL,
    [Serial_Number_Prefix]  VARCHAR (3) NOT NULL,
    CONSTRAINT [PK_SerialNumberPrefix] PRIMARY KEY CLUSTERED ([SerialNumberPrefix_ID] ASC)
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberPrefix'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberPrefix_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberPrefix'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Serial_Number_Prefix';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Lookup table for Serial Number Prefix https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberPrefix'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberPrefix_Serial_Number_Prefix]
    ON [SOC].[SerialNumberPrefix]([Serial_Number_Prefix] ASC);

