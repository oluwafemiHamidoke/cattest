CREATE TABLE [sissearch2].[Media_SNP](
	[ID] [varchar](50) NOT NULL,
	[Media_Number] [varchar](50) NOT NULL,
	[SerialNumbers] [varchar](max) NOT NULL,
	[InsertDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
);