CREATE TABLE [sis].[PartHistory] (
    [Part_ID]         INT            NOT NULL,
    [Sequence_Number] INT            NOT NULL,
    [Non_Returnable]  BIT            NULL,
    [Weight_in_Pound] NUMERIC (9, 2) NULL,
    [Change_Level]    CHAR (2)      NOT NULL,
    [Country_Code]    CHAR (2)       NULL,
    CONSTRAINT [PK_Part_NPR_Info] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Sequence_Number] ASC),
    CONSTRAINT [FK_Part_NPR_Info_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);



