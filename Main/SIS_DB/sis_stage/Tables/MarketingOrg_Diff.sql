CREATE TABLE [sis_stage].[MarketingOrg_Diff] (
    [Operation]         VARCHAR (50) NOT NULL,
    [MarketingOrg_ID]   INT          NOT NULL,
    [MarketingOrg_Code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MarketingOrg_Diff] PRIMARY KEY CLUSTERED ([MarketingOrg_ID] ASC)
);

