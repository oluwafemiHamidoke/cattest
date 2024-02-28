Create Table [SISWEB_OWNER].[LNKFILEREPLACEMENTHIERARCHY] (
    FILERID             NUMERIC(38)   NOT NULL,
    REPLACEDBYFILERID   NUMERIC(38)   NOT NULL,
    SEQNO               NUMERIC(16,0) NOT NULL,
    LASTMODIFIEDDATE    DATETIME2(6)  NULL,
    CONSTRAINT [LNKFILEREPLACEMENTHIERARCHY_PK_LNKFILEREPLACEMENTHIERARCHY] PRIMARY KEY CLUSTERED ([FILERID] ASC, [REPLACEDBYFILERID] ASC)
);
