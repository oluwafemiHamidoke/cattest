CREATE TABLE [SISWEB_OWNER_STAGING].[LNKEPSVEHICLESNPSPECS] (
    [SPECRID]    NUMERIC(16,0) NOT NULL,  
    [VEHICLESNP] VARCHAR(3) NOT NULL, 
    CONSTRAINT [LNKEPSVEHICLESNPSPECS_PK_LNKEPSVEHICLESNPSPECS] PRIMARY KEY CLUSTERED ([SPECRID] ASC, [VEHICLESNP] ASC),
    CONSTRAINT [FK_LNKEPSVEHICLESNPSPECS_SR] FOREIGN KEY ([SPECRID]) REFERENCES [SISWEB_OWNER_STAGING].[MASEPSSPECS] ([SPECRID])
);