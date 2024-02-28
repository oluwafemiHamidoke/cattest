CREATE TABLE [sis_stage].[MarketingOrg_Key] (
    [MarketingOrg_ID]   INT          IDENTITY (1, 1) NOT NULL,
    [MarketingOrg_Code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MarketingOrg_Key] PRIMARY KEY CLUSTERED ([MarketingOrg_Code] ASC)
);

