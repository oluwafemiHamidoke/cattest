CREATE TABLE [sp].[Part] (
    [Part_ID]           INT          NOT NULL,
    [ICO_icoId]         VARCHAR (25) NULL, -- Currently not populated
    [Class_ID]          INT          NOT NULL,
    [Part_Number]       VARCHAR (25) NULL,
    [LastModified_Date] DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_Part_Part_ID] PRIMARY KEY CLUSTERED ([Part_ID] ASC),
    CONSTRAINT [FK_Part_Class_ID] FOREIGN KEY ([Class_ID]) REFERENCES [sp].[Class] ([Class_ID]),
    CONSTRAINT [UQ_Part_Part_Number] UNIQUE NONCLUSTERED ([Part_Number] ASC)
);
GO
CREATE NONCLUSTERED INDEX [NCI_Part_Class_ID] 
    ON [sp].[Part] ([Class_ID] ASC)
    INCLUDE ([Part_Number]) 

