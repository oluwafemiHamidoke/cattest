CREATE TABLE [EMP_STAGING].[LNKPARTSPDFPSID] (
    [PARTSPDF_ID]           INT         NOT NULL,
    [PSID]                  VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_LNKPARTSPDFPSID] PRIMARY KEY CLUSTERED ([PARTSPDF_ID] ASC, [PSID] ASC)
);


GO
ALTER TABLE [EMP_STAGING].[LNKPARTSPDFPSID] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO