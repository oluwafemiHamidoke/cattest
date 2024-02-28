CREATE TABLE [sis_stage].[IE_ProductFamily_Effectivity] (
    [IE_ID]            INT NOT NULL,
    [ProductFamily_ID] INT NOT NULL,
    [Media_ID] INT  NOT NULL , 
    CONSTRAINT [PK_IE_ProductFamily_Effectivity] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [ProductFamily_ID] ASC, Media_ID ASC)
);

