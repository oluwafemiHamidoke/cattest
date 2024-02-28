Create Table [SISWEB_OWNER].[LNKFILESEARCHCRITERIA] (
    [FILERID]               [NUMERIC](38)           NOT NULL,
    [INFOTYPEID]            [NUMERIC](3)            NOT NULL,
    [SEARCHRECORDTYPE]      [VARCHAR](8)            NOT NULL,
    [CHARDATA]              [NVARCHAR](1080)        NULL,
    [BEGRANGE]              [NUMERIC](38)           NULL,
    [ENDRANGE]              [NUMERIC](38)           NULL,
    [NUMDATA]               [NUMERIC](38)           NULL,
    [LASTMODIFIEDDATE]      [DATETIME2](6)          NULL
);
GO
CREATE NONCLUSTERED INDEX [LNKFILESEARCHCRITERIA_FILERID]
    ON [SISWEB_OWNER].[LNKFILESEARCHCRITERIA]([FILERID] ASC);