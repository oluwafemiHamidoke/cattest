CREATE TABLE [sis].[Part_IE_Effectivity]
(
	IE_ID					INT NOT NULL,
	Part_ID					INT NOT NULL,
	Media_ID				INT NOT NULL,
	SerialNumberPrefix_ID	INT NOT NULL,
	SerialNumberRange_ID	INT NOT NULL
	,CONSTRAINT FK_Part_IE_Effectivity_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT [FK_Part_IE_Effectivity_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
	,CONSTRAINT [FK_Part_IE_Effectivity_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
	,CONSTRAINT FK_Part_IE_Effectivity_SerialNumberPrefix FOREIGN KEY(SerialNumberPrefix_ID) REFERENCES sis.SerialNumberPrefix(SerialNumberPrefix_ID)
	,CONSTRAINT FK_Part_IE_Effectivity_SerialNumberRange FOREIGN KEY(SerialNumberRange_ID) REFERENCES sis.SerialNumberRange(SerialNumberRange_ID)
);

GO
CREATE NONCLUSTERED INDEX XI_Part_IE_Effectivity_IE_ID_Part_ID_SerialNumberPrefix_ID_SerialNumberRange_ID
ON [sis].[Part_IE_Effectivity] ([IE_ID])
INCLUDE ([Part_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID])
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_ID] ON [sis].[Part_IE_Effectivity]
(
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [Part_IE_Effectivity_Media_ID]
ON [sis].[Part_IE_Effectivity] ([Media_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
	ON [sis].[Part_IE_Effectivity]([SerialNumberPrefix_ID])