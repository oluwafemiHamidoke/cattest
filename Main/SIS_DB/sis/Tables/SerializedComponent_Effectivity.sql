CREATE TABLE [sis].[SerializedComponent_Effectivity] (
    [SerializedComponent_Effectivity_ID] INT          NOT NULL,
    [AsShippedPart_Effectivity_ID]       INT          NOT NULL,
    [SerialNumber]                       VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_SerializedComponent_Effectivity] PRIMARY KEY CLUSTERED ([SerializedComponent_Effectivity_ID] ASC),
    CONSTRAINT [FK_SerializedComponent_Effectivity_AsShippedPart_Effectivity] FOREIGN KEY ([AsShippedPart_Effectivity_ID]) REFERENCES [sis].[AsShippedPart_Effectivity] ([AsShippedPart_Effectivity_ID])
);
