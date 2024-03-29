CREATE TABLE [SISWEB_OWNER_STAGING].[LNKEPSSPRINGSPECS] (
    [SPECRID]            NUMERIC(16,0) NOT NULL,  
    [GOVERNORBUMPERIND]  CHAR(1)     NOT NULL,     
    [PARTNUMBER]         VARCHAR(7) NOT NULL, 
    [LENGTH]                     NUMERIC(38,2), 
    [RATE]                       NUMERIC(38,2),
    CONSTRAINT [LNKEPSSPRINGSPECS_PK_LNKEPSSPRINGSPECS] PRIMARY KEY CLUSTERED ([SPECRID] ASC, [PARTNUMBER] ASC),
    CONSTRAINT [FK_LNKEPSSPRINGSPECS_SR] FOREIGN KEY ([SPECRID]) REFERENCES [SISWEB_OWNER_STAGING].[MASEPSSPECS] ([SPECRID])
);