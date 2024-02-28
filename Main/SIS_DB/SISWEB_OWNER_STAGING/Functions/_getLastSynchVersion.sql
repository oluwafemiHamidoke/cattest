-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200108
-- Description: Returns the last synch version number as stored in the _LAST_SYNCHRONIZATION_VERSIONS table
--				for the table passed as a parameter
-- =============================================
CREATE FUNCTION SISWEB_OWNER_STAGING._getLastSynchVersion
	(@FULLTABLENAME NVARCHAR(128)) 
RETURNS BIGINT
AS
	BEGIN
		DECLARE @LAST_SYNCHRONIZATION_VERSION BIGINT;
		SELECT @LAST_SYNCHRONIZATION_VERSION = LAST_SYNCHRONIZATION_VERSION
		  FROM SISWEB_OWNER_STAGING._LAST_SYNCHRONIZATION_VERSIONS
		  WHERE TABLENAME = @FULLTABLENAME;
		RETURN @LAST_SYNCHRONIZATION_VERSION;
	END;
GO

