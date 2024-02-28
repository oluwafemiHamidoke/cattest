CREATE TABLE [sissearch2].[YellowmarkIEPart] (
    [IESystemControlNumber] VARCHAR (12)  NOT NULL,
    [ID]                    VARCHAR (50)  NOT NULL,
    [YELLOWMARKIEPART]      VARCHAR (MAX) NULL,
    [INSERTDATE]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);