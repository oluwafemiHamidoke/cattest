CREATE TABLE [sp].[Part_Properties] (
    [Part_ID]                INT           NOT NULL,
    [Attribute_ID]           INT           NOT NULL,
    [Property_Value]         VARCHAR (MAX) NULL,
    [Property_Numeric_Value] AS            (TRY_CAST([Property_Value] AS [numeric](11,4))),
    [LastModified_Date]      DATETIME2(7)  NOT NULL,
    CONSTRAINT [PK_Part_Properties_Part_ID_Attribute_ID] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Attribute_ID] ASC),
    CONSTRAINT [FK_Part_Properties_Attribute_ID] FOREIGN KEY ([Attribute_ID]) REFERENCES [sp].[Attribute] ([Attribute_ID]),
    CONSTRAINT [FK_Part_Properties_Part_ID] FOREIGN KEY ([Part_ID]) REFERENCES [sp].[Part] ([Part_ID])
);
