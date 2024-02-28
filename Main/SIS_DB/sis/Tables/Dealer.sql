CREATE TABLE sis.Dealer
	(Dealer_ID   INT NOT NULL
	,Dealer_Code VARCHAR(50) NULL
	,CONSTRAINT PK_Dealer PRIMARY KEY CLUSTERED(Dealer_ID ASC));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Dealer'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Dealer_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Dealer'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Dealer_Code';