CREATE TABLE [sis_stage].[ProductSubfamily] (
    [ProductSubfamily_ID] INT          NULL,
    [Subfamily_Code]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Product_Subfamily] PRIMARY KEY CLUSTERED ([Subfamily_Code] ASC)
);