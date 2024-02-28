CREATE TABLE [sp].[List_Of_Values] (
    [List_Of_Values_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [List_Of_Values_Number] VARCHAR (10) NULL,
    [List_Of_Values_Name]   VARCHAR (50) NULL,
    [LastModified_Date] [DATETIME2](7) NOT NULL,
    CONSTRAINT [PK_List_Of_Values] PRIMARY KEY CLUSTERED ([List_Of_Values_ID] ASC),
    CONSTRAINT [UQ_List_Of_Values_Number] UNIQUE NONCLUSTERED ([List_Of_Values_Number] ASC)
);

