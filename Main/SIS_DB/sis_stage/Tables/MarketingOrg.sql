CREATE TABLE [sis_stage].[MarketingOrg] (
    [MarketingOrg_ID]   INT          NULL,
    [MarketingOrg_Code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MarketingOrg] PRIMARY KEY CLUSTERED ([MarketingOrg_Code] ASC)
);

