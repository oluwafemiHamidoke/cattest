CREATE TABLE [sis_stage].[SupersessionChain_Key] (
    [SupersessionChain_ID] INT            IDENTITY (1, 1) NOT NULL,
    [SupersessionChain]    VARCHAR (8000) NOT NULL,
    CONSTRAINT [PK_SupersessionChain_Key] PRIMARY KEY CLUSTERED ([SupersessionChain_ID] ASC)
);