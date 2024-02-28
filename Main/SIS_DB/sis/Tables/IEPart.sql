CREATE TABLE [sis].[IEPart] (
    [IEPart_ID]                   INT          NOT NULL,
    [Part_ID]                     INT          NOT NULL,
    [Base_English_Control_Number] VARCHAR (50) NOT NULL,
    [Publish_Date]                DATETIME     NOT NULL,
    [Update_Date]                 DATETIME     NULL,
    [IE_Control_Number]           VARCHAR (20) NULL,
    [PartName_for_NULL_PartNum] VARCHAR(128) NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_IEPart] PRIMARY KEY CLUSTERED ([IEPart_ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_IEPart_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);






GO
CREATE NONCLUSTERED INDEX NCI_IEPart_Part ON [sis].[IEPart] 
([Part_ID] ASC)
INCLUDE(Base_English_Control_Number, Update_Date, IE_Control_Number);
GO