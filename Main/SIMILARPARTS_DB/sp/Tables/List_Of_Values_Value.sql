CREATE TABLE [sp].[List_Of_Values_Value] (
    [List_Of_Values_Value_ID]   INT    IDENTITY NOT NULL,
    [List_Of_Values_ID]         INT          NOT NULL,
    [List_Of_Values_Value_Key]  VARCHAR (100) NULL,
    [List_Of_Values_Value_Name] VARCHAR (100) NULL,
    [LastModified_Date] [DATETIME2](7) NOT NULL,
    CONSTRAINT [PK_List_Of_Values_Value] PRIMARY KEY CLUSTERED ([List_Of_Values_Value_ID] ASC),
    CONSTRAINT [FK_List_Of_Values_Value_List_Of_Values] FOREIGN KEY ([List_Of_Values_ID]) REFERENCES [sp].[List_Of_Values] ([List_Of_Values_ID])
);

