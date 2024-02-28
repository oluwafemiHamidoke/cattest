CREATE SCHEMA [EMP_STAGING]
    AUTHORIZATION [dbo];

GO

GRANT SELECT,UPDATE,INSERT,DELETE ON SCHEMA ::EMP_STAGING TO [empautomation];
GO

GRANT EXECUTE ON SCHEMA ::EMP_STAGING TO [empautomation];
GO

-- This is required as there are TYPE in dbo schema that are used in some stored procedure in EMP_STAGING
GRANT EXECUTE ON SCHEMA ::dbo TO [empautomation];
GO