CREATE TABLE [sis_stage].[Dealer_Diff] (
    [Operation]   VARCHAR (50) NOT NULL,
    [Dealer_ID]   INT          NULL,
    [Dealer_Code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Dealer_Diff] PRIMARY KEY CLUSTERED ([Dealer_Code] ASC)
);

