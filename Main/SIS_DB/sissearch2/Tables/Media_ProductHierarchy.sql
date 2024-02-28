CREATE TABLE [sissearch2].[Media_ProductHierarchy](
	[ID] [varchar](50) NOT NULL,
	[Media_Number] [varchar](50) NOT NULL,
	[familyCode] [varchar](max) NULL,
	[familySubFamilyCode] [varchar](max) NULL,
	[familySubFamilySalesModel] [varchar](max) NULL,
	[familySubFamilySalesModelSNP] [varchar](max) NULL,
	[InsertDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
);