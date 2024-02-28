CREATE TABLE [sis].[IEPart_Effectivity] (
    [IEPart_ID]               INT      NOT NULL,
    [SerialNumberPrefix_ID]   INT      NOT NULL,
    [SerialNumberRange_ID]    INT      NOT NULL,
    [SerialNumberPrefix_Type] CHAR (1) DEFAULT ('N') NOT NULL,
    [Media_ID] INT NOT NULL,
	[LastModified_Date] DATETIME2(0) DEFAULT(GETDATE()) NOT NULL,
    CONSTRAINT [PK_IEPart_Effectivity] PRIMARY KEY CLUSTERED ([IEPart_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [SerialNumberPrefix_Type] ASC, [Media_ID] ASC),
    CONSTRAINT [FK_IEPart_Effectivity_IEPart] FOREIGN KEY ([IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID]),
    CONSTRAINT [FK_IEPart_Effectivity_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_IEPart_Effectivity_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
	CONSTRAINT [FK_IEPart_Effectivity_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_Part_IEPart_Effectivity_IEPart] ON [sis].[IEPart_Effectivity]
(
	[IEPart_ID] ASC,
	[SerialNumberPrefix_ID] ASC,
	[Media_ID] ASC
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IEPart_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IEPart_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IEPart_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberPrefix_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IEPart_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberRange_ID';
GO

Create nonclustered index IX_IEPart_Effectivity_SerialNumberPrefix_ID on sis.IEPart_Effectivity (SerialNumberPrefix_ID)  ;
GO
Create nonclustered index IX_IEPart_Effectivity_SerialNumberRange_ID on sis.IEPart_Effectivity (SerialNumberRange_ID)  ;
GO
CREATE NONCLUSTERED INDEX [IEPart_Effectivity_Media_ID]
ON [sis].[IEPart_Effectivity] ([Media_ID])