CREATE TYPE [dbo].UDTT_PDF_PRODUCTINSTANCE_INSERT_IN AS TABLE
(
	PARTSPDF_ID INT,
	NUMBER      varchar(60)
	PRIMARY KEY NONCLUSTERED
	(
		PARTSPDF_ID ASC,
		NUMBER      ASC
	)
)
GO