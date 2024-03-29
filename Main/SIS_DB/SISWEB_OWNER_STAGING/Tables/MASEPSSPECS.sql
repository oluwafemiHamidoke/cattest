CREATE TABLE [SISWEB_OWNER_STAGING].[MASEPSSPECS] (
    [SPECRID]             NUMERIC(16,0) NOT NULL,  
    [SERIALNUMBER]        VARCHAR(8) NOT NULL, 
    [TESTSPEC]            VARCHAR(7) NOT NULL, 
    [FULLLOADPOWER]                NUMERIC(38,1),
    [MAKEFROMSPEC]                 VARCHAR(7),
    [COMBUSTION]                   VARCHAR(2),
    [ASPIRATION]                   VARCHAR(6),
    [FLSTATICFUELSETTING]          NUMERIC(38,2),
    [FTSTATICFUELSETTING]          NUMERIC(38,2),
    CONSTRAINT [MASEPSSPECS_PK_MASEPSSPECS] PRIMARY KEY CLUSTERED ([SPECRID] ASC)
);