CREATE TABLE [sissearch2].[Media_ProductFamily](
	[ID] [varchar](50) NOT NULL,
	[Media_Number] [varchar](15) NOT NULL,
	[ProductCode] [varchar](max) NULL,
	[InsertDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
);