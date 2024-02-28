CREATE TABLE [sis_stage].[IEPart_Key] (
    [IEPart_ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [Base_English_Control_Number] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_IEPart_Key] PRIMARY KEY CLUSTERED ([IEPart_ID] ASC)
);