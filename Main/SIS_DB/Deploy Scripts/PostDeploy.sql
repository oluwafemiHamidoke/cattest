--No action taken;  Post deploy scripts
--:r "./Lookup Tables/SOC.ComponentCodeCategories.sql"
--:r "./Lookup Tables/SISWEB_OWNER_STAGING._LAST_SYNCHRONIZATION_VERSIONS.sql"
--:r "./Lookup Tables/Restore admin.User.sql"

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = 1; 

IF EXISTS (SELECT configuration_id FROM sys.database_scoped_configurations WHERE name = N'OPTIMIZE_FOR_AD_HOC_WORKLOADS' AND value = 0)
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZE_FOR_AD_HOC_WORKLOADS = ON;


IF EXISTS (SELECT configuration_id FROM sys.database_scoped_configurations WHERE name = N'MAXDOP' AND value <> 8)
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
