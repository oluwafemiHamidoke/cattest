CREATE TABLE [sissearch2].[Media_InfoType](
	[ID] [varchar](50) NOT NULL,
	[Media_Number] [varchar](15) NOT NULL,
	[InformationType] [varchar](max) NULL,
	[InsertDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
);