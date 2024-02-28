CREATE TABLE [sp].[Attribute] (
    [Attribute_ID]          INT IDENTITY  NOT NULL,
    [Attribute_Number]      VARCHAR (15) NULL,
    [Attribute_Name]        VARCHAR (80) NULL,
    [Attribute_Format]      VARCHAR (13) NULL,
    [Attribute_Unit]        VARCHAR (50) NULL,
    [FormatInteger_scale]   INT          NULL,
    [FormatString_scale]    INT          NULL,
    [FormatFloat_sign]      TINYINT      NULL,
    [FormatFloat_precision] SMALLINT     NULL,
    [FormatFloat_scale]     SMALLINT     NULL,
    [List_Of_Values_ID]     INT          NULL,
    [LastModified_Date] [DATETIME2](7) NOT NULL,
    CONSTRAINT [PK_Attribute] PRIMARY KEY CLUSTERED ([Attribute_ID] ASC),
    CONSTRAINT [UQ_Attribute_Number] UNIQUE NONCLUSTERED ([Attribute_Number] ASC)
);