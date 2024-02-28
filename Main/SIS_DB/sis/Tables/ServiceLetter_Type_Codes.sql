CREATE TABLE [sis].[ServiceLetter_Type_Codes] (
    [InfoTypeID] SMALLINT     NOT NULL,
    [OrgCode]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ServiceLetter_Type_Codes_InfoTypeID] PRIMARY KEY CLUSTERED ([InfoTypeID] ASC, [OrgCode] ASC)
);