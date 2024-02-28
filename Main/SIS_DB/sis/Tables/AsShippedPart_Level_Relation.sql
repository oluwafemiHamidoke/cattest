CREATE TABLE [sis].[AsShippedPart_Level_Relation] (
    [PartSequenceNumber]     NUMERIC (10)     NOT NULL,
    [SerialNumberPrefix_ID]  INT			  NOT NULL,
    [SerialNumberRange_ID]   INT			  NOT NULL,
    [PartNumber]             VARCHAR(20)      NULL,
    [Part_ID]                INT			  NOT NULL,
    [ParentPartNumber]       VARCHAR (60)     NULL,
    [AttachmentSerialNumber] VARCHAR (20)     NULL,
    [PartOrder]              NUMERIC (10)     NOT NULL,
    [PartLevel]              NUMERIC (1)      NOT NULL,
    [PartType]               VARCHAR (25)     NULL,
    CONSTRAINT [PK_AsShippedPart_Level_Relation] PRIMARY KEY CLUSTERED([SerialNumberPrefix_ID] ASC,[SerialNumberRange_ID] ASC,[PartLevel] ASC,[Part_ID] ASC,[PartOrder] ASC,[PartSequenceNumber] ASC),
    CONSTRAINT [FK_AsShippedPart_Level_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_AsShippedPart_Level_Relation_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_AsShippedPart_Level_Relation_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
    );

GO
CREATE NONCLUSTERED INDEX [AsShippedPart_Level_Relation_Prefix_Range_Part_Parent_Part_ID_Attachment_PartOrder_PartLevel] ON [sis].[AsShippedPart_Level_Relation]
(
	[SerialNumberPrefix_ID] ASC,
	[SerialNumberRange_ID] ASC,
	[PartOrder] ASC
)
INCLUDE (
	[PartSequenceNumber],
	[PartNumber],
	[Part_ID],
	[ParentPartNumber],
	[AttachmentSerialNumber],
	[PartLevel])
GO
CREATE NONCLUSTERED INDEX [IDX_Level_Prefix_Range] ON [sis].[AsShippedPart_Level_Relation]
(
	[PartLevel] ASC,
	[SerialNumberPrefix_ID] ASC,
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_ID] ON [sis].[AsShippedPart_Level_Relation]
(
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [AsShippedPart_Level_Relation_PartID] ON [sis].[AsShippedPart_Level_Relation]
(
	[Part_ID] ASC
);
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID]
    ON [sis].[AsShippedPart_Level_Relation] ([SerialNumberPrefix_ID])