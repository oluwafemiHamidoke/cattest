CREATE SCHEMA [SISSEARCH]
    AUTHORIZATION [dbo];


GO

GRANT ALTER
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

GRANT DELETE
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

--GRANT DELETE
--    ON SCHEMA::[SISSEARCH] TO [siscontainerservice];
--GO

GRANT EXECUTE
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

GRANT INSERT
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

--GRANT INSERT
--    ON SCHEMA::[SISSEARCH] TO [siscontainerservice];
--GO

GRANT SELECT
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

--GRANT SELECT
--    ON SCHEMA::[SISSEARCH] TO [siscontainerservice];
--GO

GRANT SELECT
    ON SCHEMA::[SISSEARCH] TO [sissearchdatasource];
GO

GRANT UPDATE
    ON SCHEMA::[SISSEARCH] TO [sisautomation];
GO

--GRANT UPDATE
--    ON SCHEMA::[SISSEARCH] TO [siscontainerservice];
--GO

GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[SISSEARCH] TO [sissearchdatasource];
GO

