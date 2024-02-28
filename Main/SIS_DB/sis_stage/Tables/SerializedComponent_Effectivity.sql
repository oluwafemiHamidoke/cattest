CREATE TABLE [sis_stage].[SerializedComponent_Effectivity] (
    [SerializedComponent_Effectivity_ID] INT          NULL,
    [AsShippedPart_Effectivity_ID]       INT          NOT NULL,
    [SerialNumber]                       VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_SerializedComponent_Effectivity] PRIMARY KEY CLUSTERED ([AsShippedPart_Effectivity_ID] ASC, [SerialNumber] ASC)
);