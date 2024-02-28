CREATE TABLE [sis_stage].[IEPart] (
    [IEPart_ID]                   INT          NULL,
    [Part_ID]                     INT          NOT NULL,
    [Base_English_Control_Number] VARCHAR (50) NOT NULL,
    [Publish_Date]                DATETIME     NOT NULL,
    [Update_Date]                 DATETIME     NULL,
    [IE_Control_Number]           VARCHAR (20) NULL,
    [PartName_for_NULL_PartNum] VARCHAR(128) NULL, 
    CONSTRAINT [PK_IEPart] PRIMARY KEY CLUSTERED ([Base_English_Control_Number] ASC) WITH (FILLFACTOR = 100)
);

