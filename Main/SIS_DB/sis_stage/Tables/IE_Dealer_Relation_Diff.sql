CREATE TABLE [sis_stage].[IE_Dealer_Relation_Diff] (
    [Operation] VARCHAR (50) NOT NULL,
    [IE_ID]     INT          NOT NULL,
    [Dealer_ID] INT          NOT NULL,
    CONSTRAINT [PK_IE_Dealer_Relation_Diff] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [Dealer_ID] ASC)
);

