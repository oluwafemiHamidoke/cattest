CREATE TABLE [SISSEARCH].[SERVICEIETEXT_2] (
    [IESystemControlNumber] VARCHAR (50)  NOT NULL,
    [IEContent]             VARCHAR (MAX) NOT NULL,
    [LanguageIdicator]      VARCHAR (25)  NOT NULL,
    [LastProcessedDate]     DATETIME2 (7) NOT NULL,
    [SourceDataType]        VARCHAR (20)  NOT NULL,
    PRIMARY KEY CLUSTERED ([IESystemControlNumber] ASC)
);