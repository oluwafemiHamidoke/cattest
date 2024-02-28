CREATE TABLE [sis_stage].[SerializedComponent_Effectivity_Key] (
    [SerializedComponent_Effectivity_ID] INT          IDENTITY (1, 1) NOT NULL,
    [AsShippedPart_Effectivity_ID]       INT          NOT NULL,
    [SerialNumber]                       VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_SerializedComponent_Effectivity_Key] PRIMARY KEY CLUSTERED ([SerializedComponent_Effectivity_ID] ASC)
);