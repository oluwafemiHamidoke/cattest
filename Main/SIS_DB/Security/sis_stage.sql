CREATE SCHEMA [sis_stage]
    AUTHORIZATION [dbo];

GO
GRANT UPDATE
    ON SCHEMA::[sis_stage] TO [sisadf];


GO
GRANT SELECT
    ON SCHEMA::[sis_stage] TO [sisadf];


GO
GRANT INSERT
    ON SCHEMA::[sis_stage] TO [sisadf];


GO
GRANT DELETE
    ON SCHEMA::[sis_stage] TO [sisadf];


GO
GRANT ALTER
    ON SCHEMA::[sis_stage] TO [sisadf];