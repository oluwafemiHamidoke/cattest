CREATE TABLE [sis].[NprInfo] (
    [PARTNUMBER]               VARCHAR (20)  NOT NULL,
    [COUNTRYCODE]              VARCHAR (2)   NOT NULL,
    [ENGGCHANGELEVELNO]        VARCHAR (2)   NOT NULL,
    [PRIMARYSEQNO]             INT           NOT NULL,
    [PARTNUMBERDESCRIPTION]    VARCHAR (200) NULL,
    [NONRETURNABLEINDICATOR]   VARCHAR (1)   NULL,
    [PARTREPLACEMENTINDICATOR] VARCHAR (1)   NULL,
    [PACKAGEQUANTITY]          VARCHAR (8)   NULL,
    [WEIGHT]                   INT           NULL,
    [CANCELLEDNPRINFORMATION]  VARCHAR (20)  NULL,
    [NPRINDICATOR]             VARCHAR (20)  NULL,
    [LASTMODIFIEDDATE]         DATETIME2 (6) NULL,
    CONSTRAINT [NPRINFO_PK] PRIMARY KEY CLUSTERED ([PARTNUMBER] ASC, [COUNTRYCODE] ASC, [ENGGCHANGELEVELNO] ASC, [PRIMARYSEQNO] ASC)
);