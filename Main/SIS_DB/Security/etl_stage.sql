CREATE SCHEMA [etl_stage]
    AUTHORIZATION [dbo];

GO

GRANT SELECT,UPDATE,INSERT,DELETE ON SCHEMA ::etl_stage TO [sis2etl];
GO

GRANT EXECUTE ON SCHEMA ::etl_stage TO [sis2etl];
GO

-- This is required as there are TYPE in dbo schema that are used in some stored procedure in EMP_STAGING
GRANT EXECUTE ON SCHEMA ::dbo TO [sis2etl];
GO