CREATE TYPE [dbo].UDTT_LNKIEIMAGE_MASIMAGELOCATION_INSERT_IN AS TABLE
(
	IESYSTEMCONTROLNUMBER varchar(12),
	GRAPHICSEQUENCENUMBER SMALLINT,
	GRAPHICCONTROLNUMBER  varchar(60) ,
	IMAGETYPE             varchar(1),
	GRAPHICUPDATEDATE     DATETIME2,
	IMAGELOCATION         varchar(100),
	LASTMODIFIEDDATE      DATETIME2
	PRIMARY KEY NONCLUSTERED
	(
		GRAPHICCONTROLNUMBER ASC,
		IMAGETYPE            ASC
	)
)
GO