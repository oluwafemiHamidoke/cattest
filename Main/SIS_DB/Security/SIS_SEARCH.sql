CREATE SCHEMA [SIS_SEARCH]
    AUTHORIZATION [dbo];


GO
GRANT ALTER
    ON SCHEMA::[SIS_SEARCH] TO [sisautomation];


GO
GRANT DELETE
    ON SCHEMA::[SIS_SEARCH] TO [sisautomation];


GO
GRANT INSERT
    ON SCHEMA::[SIS_SEARCH] TO [sisautomation];


GO
GRANT SELECT
    ON SCHEMA::[SIS_SEARCH] TO [sisautomation];


GO
GRANT SELECT
    ON SCHEMA::[SIS_SEARCH] TO [sissearchdatasource];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[SIS_SEARCH] TO [sissearchdatasource];

