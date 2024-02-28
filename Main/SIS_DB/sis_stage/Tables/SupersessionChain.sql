CREATE TABLE [sis_stage].[SupersessionChain] (
    [SupersessionChain_ID] INT            NULL,
    [SupersessionChain]    VARCHAR (8000) NOT NULL,
    CONSTRAINT [PK_SupersessionChain] PRIMARY KEY CLUSTERED ([SupersessionChain] ASC)
);