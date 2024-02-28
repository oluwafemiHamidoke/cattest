/****** Object:  Table [sissearch2].[ServiceIE_RestrictAccess]    Script Date: 8/23/2022 10:27:55 AM ******/
CREATE TABLE [sissearch2].[ServiceIE_RestrictAccess](
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [RestrictionCode]       VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IESystemControlNumber] ASC)
);


