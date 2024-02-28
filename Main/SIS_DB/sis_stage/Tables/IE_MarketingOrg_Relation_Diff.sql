CREATE TABLE [sis_stage].[IE_MarketingOrg_Relation_Diff] (
    [Operation]       VARCHAR (50) NOT NULL,
    [IE_ID]           INT          NOT NULL,
    [MarketingOrg_ID] INT          NOT NULL,
    CONSTRAINT [PK_IE_MarketingOrg_Relation_Diff] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [MarketingOrg_ID] ASC)
);

