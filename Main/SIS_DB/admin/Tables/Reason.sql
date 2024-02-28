CREATE TABLE [admin].[Reason] (
    [Reason_ID]          INT NOT NULL,
    [Description] VARCHAR (50) NOT NULL,
    [Applicable_Active_Status] BIT NOT NULL DEFAULT 0, 
    [Allow_Selection] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_ReasonProfile] PRIMARY KEY CLUSTERED ([Reason_ID] ASC)
);