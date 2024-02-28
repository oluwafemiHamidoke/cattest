CREATE TABLE [SISSEARCH].[MEDIASNP_4] (
    [ID]                 VARCHAR (50)  NOT NULL,
    [BaseEngMediaNumber] VARCHAR (15)  NOT NULL,
    [SerialNumbers]      VARCHAR (MAX) NOT NULL,
    [InsertDate]         DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

