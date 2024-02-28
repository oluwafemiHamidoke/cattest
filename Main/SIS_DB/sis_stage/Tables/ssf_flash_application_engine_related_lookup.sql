CREATE TABLE sis_stage.ssf_flash_application_engine_related_lookup (
    FlashApplication_ID  INT NOT NULL,
    Application_Description VARCHAR(48),
	Is_Engine_Related VARCHAR(1) NOT NULL DEFAULT 0
)
GO