CREATE TABLE [SOC].[SerialNumberRange] (
    [SerialNumberRange_ID] INT IDENTITY (1, 1) NOT NULL,
    [Start_Serial_Number]  INT NOT NULL,
    [End_Serial_Number]    INT NOT NULL,
    CONSTRAINT [PK_SerialNumberRange] PRIMARY KEY CLUSTERED ([SerialNumberRange_ID] ASC)
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberRange'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberRange_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberRange'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Start_Serial_Number';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberRange'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'End_Serial_Number';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Lookup table for Serial Number Range https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SerialNumberRange'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_Start_Serial_Number_End_Serial_Number]
    ON [SOC].[SerialNumberRange]([Start_Serial_Number] ASC, [End_Serial_Number] ASC);

