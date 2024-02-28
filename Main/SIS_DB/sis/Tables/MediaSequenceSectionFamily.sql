CREATE TABLE [sis].[MediaSequenceSectionFamily] (
	[Media_ID] 				INT			NOT NULL, 
	[IEPart_ID] 			INT			NOT NULL,
	[MediaSection_ID]		INT			NOT NULL,
	[IESystemControlNumber] VARCHAR(12) NULL
)
GO
CREATE NONCLUSTERED INDEX [IDX_Media_ID_IEPart_ID_IESystemControlNumber] ON [sis].[MediaSequenceSectionFamily]
(
	[Media_ID] ASC,
	[IEPart_ID] ASC
)
INCLUDE([IESystemControlNumber])