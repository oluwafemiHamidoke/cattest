CREATE TABLE [sis_stage].[Dealer_Key] (
    [Dealer_ID]   INT          IDENTITY (1, 1) NOT NULL,
    [Dealer_Code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Dealer_Key] PRIMARY KEY CLUSTERED ([Dealer_ID] ASC)
);

