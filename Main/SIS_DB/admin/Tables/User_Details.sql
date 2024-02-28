CREATE TABLE [admin].[User_Details]         (
    [User_ID]                       INT Identity(1,1)   NOT NULL,
    [cws]                           VARCHAR (50)        NULL,
    [catRecID]                      VARCHAR (50)        NULL,
    [User_Name]                     nVARCHAR (150)      NOT NULL,
    [Affiliation_ID]                INT                 NOT NULL,
    [Organization_ID]               INT                 DEFAULT -1 NOT NULL,
    [Is_Technical_Communicator]     BIT                 DEFAULT ((0)) NOT NULL,
    [Created_By]                    NVARCHAR(50)        DEFAULT '' NOT NULL,
    [Created_On]                    DATETIME2(1)        DEFAULT GETUTCDATE() NOT NULL,
    [Last_Modified_By]              NVARCHAR(50)        DEFAULT '' NOT NULL,
    [Last_Modified_On]              DATETIME2(1)        DEFAULT GETUTCDATE() NOT NULL,

    CONSTRAINT [PK_User_Details] PRIMARY KEY CLUSTERED ([User_ID] ASC),
    CONSTRAINT [FK_User_Details_Affiliation] FOREIGN KEY ([Affiliation_ID]) REFERENCES [admin].[Affiliation] ([Affiliation_ID]),
    CONSTRAINT [FK_User_Details_Organization] FOREIGN KEY ([Organization_ID]) REFERENCES [admin].[Organization] ([Organization_ID]),
    CONSTRAINT [UQ_User_Details_catRecID] UNIQUE NONCLUSTERED ([catRecID] ASC),
    CONSTRAINT [UQ_User_Details_cws] UNIQUE NONCLUSTERED ([cws] ASC)
);









