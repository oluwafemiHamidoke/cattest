CREATE TABLE [sis].[IE_Dealer_Relation] (
    [IE_ID]     INT NOT NULL,
    [Dealer_ID] INT NOT NULL,
    CONSTRAINT [PK_IE_Dealer_Relation] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [Dealer_ID] ASC),
    CONSTRAINT [FK_IE_Dealer_Relation_Dealer] FOREIGN KEY ([Dealer_ID]) REFERENCES [sis].[Dealer] ([Dealer_ID]),
    CONSTRAINT [FK_IE_Dealer_Relation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Dealer_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Dealer_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Dealer_ID';

