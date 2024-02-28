CREATE TABLE [sis].[ProductStructure] (
    [ProductStructure_ID]       INT      NOT NULL,
    [ParentProductStructure_ID] INT      NULL,
    [Parentage]                 TINYINT  CONSTRAINT [DF_ProductStructure_Parentage] DEFAULT ((0)) NOT NULL,
    [MiscSpnIndicator]          CHAR (1) CONSTRAINT [DF_ProductStructure_MiscSpnIndicator] DEFAULT ('Y') NOT NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_ProductStructure] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC),
    CONSTRAINT [FK_ProductStructure_ProductStructure] FOREIGN KEY ([ParentProductStructure_ID]) REFERENCES [sis].[ProductStructure] ([ProductStructure_ID])
);
GO

CREATE INDEX IDX_productstructure_id ON [sis].[ProductStructure] (ProductStructure_ID) INCLUDE (
	Parentage
	,ParentProductStructure_ID
	)
GO

