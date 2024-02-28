CREATE TABLE [SOC].[Smcs] (
    [Smcs_ID]               INT          IDENTITY (1, 1) NOT NULL,
    [Component_Code]        NVARCHAR(50) NOT NULL,
    [Job_Code]              NVARCHAR(50) NOT NULL,
    [Modifier_Code]         NVARCHAR(50) NOT NULL,
    [Quantity_Code]         NVARCHAR(50) NOT NULL,
    [JobLocation_Code]     NVARCHAR(50) NOT NULL,
    [WorkApplication_Code] NVARCHAR(50) NOT NULL,
    [JobCondition_Code]    NVARCHAR(50) NOT NULL,
    [CabType_Code]         NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Smcs] PRIMARY KEY CLUSTERED ([Smcs_ID] ASC),
    CONSTRAINT [UQ_Smcs_All_Codes] UNIQUE NONCLUSTERED ([Component_Code] ASC, [Job_Code] ASC, [Modifier_Code] ASC, [Quantity_Code] ASC, [JobLocation_Code] ASC, [WorkApplication_Code] ASC, [JobCondition_Code] ASC, [CabType_Code] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Smcs_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.component in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Component_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.job in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Job_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.modifier in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Modifier_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.quantity in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Quantity_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.jobLocation in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = 'JobLocation_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.workApplication in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = 'WorkApplication_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.jobCondition in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = 'JobCondition_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'smcs.cabType in JSON file, NO FOREIGN KEY'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = 'CabType_Code';
GO

