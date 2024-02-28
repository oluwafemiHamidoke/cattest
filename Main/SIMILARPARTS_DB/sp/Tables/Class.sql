CREATE TABLE [sp].[Class] (
    [Class_ID]              INT                 NOT NULL,
    [Class_Number]          INT                 NULL,
    [Class_Name]            VARCHAR (60)        NULL,
    [Parent_Class_ID]       INT                 NULL,
    [Class_File_Name]       VARCHAR (100)       NULL,
    [Class_Level]           INT                 NULL,
    [Class_Hierarchy]       VARCHAR (4001)      NULL,
    [Class_Path]            VARCHAR (4000)      NULL,
    [LastModified_Date]     DATETIME2(7)        NOT NULL,
    CONSTRAINT [PK_Class_Class_ID] PRIMARY KEY NONCLUSTERED ([Class_ID] ASC),
    CONSTRAINT [UQ_Class_Class_Number] UNIQUE NONCLUSTERED ([Class_Number] ASC)
);