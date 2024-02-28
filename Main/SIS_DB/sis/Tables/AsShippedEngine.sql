CREATE TABLE [sis].[AsShippedEngine] (
    [AsShippedEngine_ID]    INT         NOT NULL,
    [Part_ID]               INT         NOT NULL,
    [SerialNumberPrefix_ID] INT         NOT NULL,
    [SerialNumberRange_ID]  INT         NOT NULL,
    [Quantity]              INT         NOT NULL,
    [Sequence_Number]       INT         NOT NULL,
    [Change_Level_Number]   VARCHAR (4) NULL,
    [Assembly]              VARCHAR (1) NULL,
    [Less_Indicator]        VARCHAR (1) NULL,
    [Indentation]           VARCHAR (1) NULL,
    CONSTRAINT [PK_AsShippedEngine] PRIMARY KEY CLUSTERED ([AsShippedEngine_ID] ASC),
    CONSTRAINT [FK_AsShippedEngine_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_AsShippedEngine_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_AsShippedEngine_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_AsShippedEngine_Part ON [sis].[AsShippedEngine] 
([Part_ID] ASC) ;
GO
Create nonclustered index IX_AsShippedEngine_SerialNumberRange_ID on sis.AsShippedEngine (SerialNumberRange_ID) ;
GO
CREATE NONCLUSTERED INDEX [IDX_AsShippedEngine_Multi_Column] ON [sis].[AsShippedEngine]
(
	[SerialNumberPrefix_ID] ASC,
	[SerialNumberRange_ID] ASC
)
INCLUDE([Part_ID],[Quantity],[Sequence_Number],[Change_Level_Number],[Assembly],[Less_Indicator],[Indentation]) 
GO

CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID]
    ON [sis].[AsShippedEngine] ([SerialNumberPrefix_ID])