CREATE TABLE [admin].[ApplicationFeature] (
    [ApplicationFeature_ID]          INT Identity(1,1)         NOT NULL,
    [ApplicationFeature_Description] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ApplicationFeature] PRIMARY KEY CLUSTERED ([ApplicationFeature_ID] ASC)
);

