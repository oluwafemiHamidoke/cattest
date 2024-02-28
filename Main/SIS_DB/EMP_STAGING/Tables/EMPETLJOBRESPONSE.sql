CREATE TABLE [EMP_STAGING].[EMPETLJOBRESPONSE] (
    [EMPETLJOBRESPONSE_ID]  INT    IDENTITY (1, 1) NOT NULL,
    [INSTANCEID]           VARCHAR (60)           NOT NULL,
    [STATUSGETURI]        VARCHAR (1024)         NOT NULL,
    [TERMINATEPOSTURI]    VARCHAR (1024)         NOT NULL,
    [TRIGGERTIME]          DATETIME2 (6)          NOT NULL,
    CONSTRAINT [PK_EMPETLJOBRESPONSE] PRIMARY KEY CLUSTERED ([EMPETLJOBRESPONSE_ID] ASC)
);

GO
CREATE NONCLUSTERED INDEX IX_SCPART_INSTANCEID
    ON EMP_STAGING.EMPETLJOBRESPONSE (INSTANCEID ASC);
GO
