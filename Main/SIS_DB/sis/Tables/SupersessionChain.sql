CREATE TABLE [sis].[SupersessionChain] (
    [SupersessionChain_ID] INT            NOT NULL,
    [SupersessionChain]    VARCHAR (8000) NOT NULL,
    CONSTRAINT [PK_SupersessionChain] PRIMARY KEY CLUSTERED ([SupersessionChain_ID] ASC)
);