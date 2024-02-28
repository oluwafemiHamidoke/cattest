CREATE TABLE sis.MediaSequence_Base
	(MediaSequence_ID         INT        NOT NULL
	,MediaSection_ID          INT        NOT NULL
	,IEPart_ID                INT        NULL
	,Sequence_Number          INT        NOT NULL
	,Serviceability_Indicator VARCHAR(1) NULL
	,IE_ID                    INT        NULL
	,[Arrangement_Indicator]  VARCHAR(1) NULL
	,[TypeChange_Indicator]   VARCHAR(1) NULL
	,[NPR_Indicator]          VARCHAR(1) NULL
	,[CCR_Indicator]          VARCHAR(1) NULL
	,[IESystemControlNumber]  VARCHAR(12)NULL
	,[Part]                   VARCHAR(10)NOT NULL DEFAULT '1'
    ,[Of_Parts]               VARCHAR(10)NOT NULL DEFAULT '1'
	,[LastModified_Date]      DATETIME   NULL
	,CONSTRAINT PK_MediaSequence PRIMARY KEY CLUSTERED(MediaSequence_ID ASC)
	,CONSTRAINT FK_MediaSequence_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT FK_MediaSequence_IEPart FOREIGN KEY(IEPart_ID) REFERENCES sis.IEPart(IEPart_ID)
	,CONSTRAINT FK_MediaSequence_MediaSection FOREIGN KEY(MediaSection_ID) REFERENCES sis.MediaSection(MediaSection_ID));
GO

GO
CREATE NONCLUSTERED COLUMNSTORE INDEX cci_MediaSequence_Base ON [sis].[MediaSequence_Base](IEPart_ID, MediaSection_ID, IESystemControlNumber)
GO
Create nonclustered index IX_MediaSequence_Base_IE_ID on sis.MediaSequence_Base (IE_ID)  INCLUDE (MediaSection_ID,Sequence_Number);

GO
CREATE NONCLUSTERED INDEX IX_MediaSequence_Base_IESystemControlNumber ON [sis].[MediaSequence_Base] ([IESystemControlNumber], [MediaSection_ID], [IEPart_ID])

GO
CREATE NONCLUSTERED INDEX [IX_MediaSequence_Base_MediaSection_ID_IEPart_ID_IESystemControlNumber] ON [sis].[MediaSequence_Base]
(
    [CCR_Indicator] DESC,
    [MediaSection_ID] ASC,
    [IEPart_ID]
) INCLUDE(IESystemControlNumber)
GO
CREATE NONCLUSTERED INDEX [IX_MediaSequence_Base_LastModified_Date]
ON [sis].[MediaSequence_Base] ([LastModified_Date])
INCLUDE ([IEPart_ID],[IESystemControlNumber])
GO

CREATE NONCLUSTERED INDEX [IX_MediaSequence_Base_IEPart_ID]
ON [sis].[MediaSequence_Base] ([IEPart_ID])
INCLUDE ([MediaSection_ID],[IESystemControlNumber])
GO

CREATE NONCLUSTERED INDEX [IX_MediaSequence_Base_MediaSection_ID_IEPart_ID] ON [sis].[MediaSequence_Base]
(
       [MediaSection_ID] ASC,
	   [IEPart_ID],
	   [IESystemControlNumber]
)
INCLUDE([IE_ID],[Sequence_Number],[Arrangement_Indicator]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO