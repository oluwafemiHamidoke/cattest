CREATE TABLE [sissearch2].[ServiceIE_ProductHierarchy](
    [ID]                           VARCHAR (50)  NOT NULL,
    [Iesystemcontrolnumber]        VARCHAR (50)  NOT NULL,
    [familyCode]                   VARCHAR (MAX) NULL,
    [familySubFamilyCode]          VARCHAR (MAX) NULL,
    [familySubFamilySalesModel]    VARCHAR (MAX) NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
    [InsertDate]                   DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

