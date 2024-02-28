Create table admin.[User_Cleanup_Audit](
    [User_ID] [int] NOT NULL,
    [cws] [varchar](50) NULL,
    [catRecID] [varchar](50) NULL,
    [User_Name] [nvarchar](150) NOT NULL,
    [Affiliation_ID] [int] NOT NULL,
    [Organization_ID] [int] DEFAULT (-1) NOT NULL,
    [Created_On] [datetime2](1) DEFAULT getutcdate() NOT NULL,
    [CleanUp_by] [nvarchar](50)  DEFAULT ('')NOT NULL,
    [Group_Profile_Mapping] Nvarchar(1000) NULL,
    CONSTRAINT [PK_User_Cleanup_Audit] PRIMARY KEY CLUSTERED (
    [User_ID] ASC
    )
);

