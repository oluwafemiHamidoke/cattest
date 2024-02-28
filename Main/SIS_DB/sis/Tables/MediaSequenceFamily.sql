CREATE TABLE [sis].[MediaSequenceFamily](
	[Media_ID] [int] NOT NULL,
	[Media_Number] [varchar](50) NOT NULL,
	[MediaSection_ID] [int] NOT NULL,
	[Arrangement_Indicator] [varchar](1) NULL,
	[CCR_Indicator] [varchar](1) NULL,
	[IEPart_ID] [int] NULL,
	[IE_ID] [int] NULL,
	[IESystemControlNumber] [varchar](12) NULL,
	[NPR_Indicator] [varchar](1) NULL,
	[Serviceability_Indicator] [varchar](1) NULL,
	[Sequence_Number] [int] NOT NULL,
	[TypeChange_Indicator] [varchar](1) NULL,
	[MediaSequence_ID] [int] NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
	[Language_ID] [int] NOT NULL,
	[Media_Origin] [varchar](2) NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[Serial_Number_Prefix] [varchar](3) NOT NULL,
	[End_Serial_Number] [int] NOT NULL,
	[Start_Serial_Number] [int] NOT NULL
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_IEPart_ID] ON [sis].[MediaSequenceFamily]
(
	[IEPart_ID] ASC,
	[Serial_Number_Prefix] ASC,
	[Media_Origin] ASC,
	[End_Serial_Number] ASC,
	[Start_Serial_Number] ASC,
	[Media_Number] ASC,
	[MediaSequence_ID] ASC
)
INCLUDE([IESystemControlNumber],[Arrangement_Indicator],[CCR_Indicator],[Media_ID],[NPR_Indicator],[SerialNumberPrefix_ID],[Serviceability_Indicator],[TypeChange_Indicator]) 
GO

			CREATE NONCLUSTERED INDEX [IDX_IEPart_ID_SNP_ID] ON [sis].[MediaSequenceFamily] (
				[IEPart_ID] ASC
				,[SerialNumberPrefix_ID] ASC
				) INCLUDE (
				[Media_Number]
				,[Arrangement_Indicator]
				,[CCR_Indicator]
				,[IESystemControlNumber]
				,[NPR_Indicator]
				,[Serviceability_Indicator]
				,[TypeChange_Indicator]
				,[Serial_Number_Prefix]
				,[End_Serial_Number]
				,[Start_Serial_Number]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_IESCN_SNP] ON [sis].[MediaSequenceFamily]
(
	[IESystemControlNumber] ASC,
	[Serial_Number_Prefix] ASC,
	[Media_Number] ASC,
	[Media_Origin] ASC
)
INCLUDE([Arrangement_Indicator],[IEPart_ID],[Media_ID],[Language_ID]) 

GO
			CREATE NONCLUSTERED INDEX [IDX_Language_ID_Serial_Number_Prefix] ON [sis].[MediaSequenceFamily] (
				[Language_ID] ASC
				,[Serial_Number_Prefix] ASC
				) INCLUDE (
				[Media_Number]
				,[IESystemControlNumber]
				,[Media_Origin]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
			CREATE NONCLUSTERED INDEX [IDX_Media_ID_IEPart_ID] ON [sis].[MediaSequenceFamily] (
				[Media_ID] ASC
				,[IEPart_ID] ASC
				) INCLUDE (
				[Media_Number]
				,[Arrangement_Indicator]
				,[CCR_Indicator]
				,[IESystemControlNumber]
				,[NPR_Indicator]
				,[Serviceability_Indicator]
				,[TypeChange_Indicator]
				,[Serial_Number_Prefix]
				,[End_Serial_Number]
				,[Start_Serial_Number]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
			CREATE NONCLUSTERED INDEX [IDX_Media_number_Origin] ON [sis].[MediaSequenceFamily] (
				[Media_Number] ASC
				,[Media_Origin] ASC
				) INCLUDE (
				[Arrangement_Indicator]
				,[CCR_Indicator]
				,[IEPart_ID]
				,[IESystemControlNumber]
				,[NPR_Indicator]
				,[Serviceability_Indicator]
				,[TypeChange_Indicator]
				,[End_Serial_Number]
				,[Start_Serial_Number]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
			CREATE NONCLUSTERED INDEX [IDX_Media_Origin] ON [sis].[MediaSequenceFamily] ([Media_Origin] ASC) INCLUDE (
				[Media_Number]
				,[Arrangement_Indicator]
				,[IEPart_ID]
				,[IESystemControlNumber]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
			CREATE NONCLUSTERED INDEX [IDX_SNP_End_Start_Origin] ON [sis].[MediaSequenceFamily] (
				[Serial_Number_Prefix] ASC
				,[Media_Origin] ASC
				,[End_Serial_Number] ASC
				,[Start_Serial_Number] ASC
				) INCLUDE (
				[IEPart_ID]
				,[Media_Number]
				,[Arrangement_Indicator]
				,[CCR_Indicator]
				,[IESystemControlNumber]
				,[NPR_Indicator]
				,[Serviceability_Indicator]
				,[TypeChange_Indicator]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
			CREATE NONCLUSTERED INDEX [IDX_SNP_Media_Origin] ON [sis].[MediaSequenceFamily] (
				[Serial_Number_Prefix] ASC
				,[Media_Origin] ASC
				) INCLUDE (
				[Media_Number]
				,[Arrangement_Indicator]
				,[IEPart_ID]
				,[IESystemControlNumber]
				,[Sequence_Number]
				)
				WITH (
						STATISTICS_NORECOMPUTE = OFF
						,DROP_EXISTING = OFF
						,ONLINE = OFF
						,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
						) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Media_ID_Media_Number_IEPart_ID] ON [sis].[MediaSequenceFamily]
(
	[Serial_Number_Prefix] ASC,
	[Media_Origin] ASC,
	[End_Serial_Number] ASC,
	[Start_Serial_Number] ASC,
	[IEPart_ID] ASC,
	[Media_ID] ASC,
	[Media_Number] ASC
)
INCLUDE([Arrangement_Indicator],[CCR_Indicator],[IESystemControlNumber],[NPR_Indicator],[Serviceability_Indicator],[TypeChange_Indicator],[SerialNumberPrefix_ID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_IESystemControlNumber] ON [sis].[MediaSequenceFamily]
(
	[IESystemControlNumber] ASC
)
INCLUDE([Media_Number],[Arrangement_Indicator],[CCR_Indicator],[IEPart_ID],[NPR_Indicator],[Serviceability_Indicator],[TypeChange_Indicator],[MediaSequence_ID],[Serial_Number_Prefix],[End_Serial_Number],[Start_Serial_Number])
GO

CREATE CLUSTERED INDEX [IDX_MediaID] ON [sis].[MediaSequenceFamily] 
(
	[Media_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_Media_Number_SNP_Media_Origin_SN_IEPart_ID]
ON [sis].[MediaSequenceFamily] ([Media_Number],[Serial_Number_Prefix],[Media_Origin],[End_Serial_Number],[Start_Serial_Number])
INCLUDE ([IEPart_ID])
GO



