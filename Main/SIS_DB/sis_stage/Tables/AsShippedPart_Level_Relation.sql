CREATE TABLE [sis_stage].[AsShippedPart_Level_Relation] (
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
    CONSTRAINT [PK_AsShippedPart_Level_Relation] PRIMARY KEY CLUSTERED([SerialNumberPrefix_ID] ASC,[SerialNumberRange_ID] ASC,[PartLevel] ASC,[Part_ID] ASC,[PartOrder] ASC,[PartSequenceNumber] ASC)
    );
