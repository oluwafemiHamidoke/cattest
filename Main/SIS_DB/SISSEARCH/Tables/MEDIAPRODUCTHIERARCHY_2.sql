CREATE TABLE [SISSEARCH].[MEDIAPRODUCTHIERARCHY_2] (
    [ID]                           VARCHAR (50)  NOT NULL,
    [BaseEngMediaNumber]           VARCHAR (50)  NOT NULL,
    [familyCode]                   VARCHAR (MAX) NULL,
    [familySubFamilyCode]          VARCHAR (MAX) NULL,
    [familySubFamilySalesModel]    VARCHAR (MAX) NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
    [InsertDate]                   DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);