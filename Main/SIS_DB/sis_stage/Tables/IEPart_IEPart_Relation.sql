CREATE TABLE [sis_stage].[IEPart_IEPart_Relation]
(
	[IEPart_ID] INT NOT NULL,
	[Related_IEPart_ID] INT NOT NULL,
    [Media_ID]          int NOT NULL,

	CONSTRAINT [PK_IEPart_IEPart_Relation_stage] 
	PRIMARY KEY CLUSTERED ([IEPart_ID] ASC, [Related_IEPart_ID] ASC,[Media_ID] ASC)
)
