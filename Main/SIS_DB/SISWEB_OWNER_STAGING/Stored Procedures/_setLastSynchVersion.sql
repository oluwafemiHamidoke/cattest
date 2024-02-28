-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200108
-- Description: Returns the last synch version number as stored in the _LAST_SYNCHRONIZATION_VERSIONS table
--				for the table passed as a parameter
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING._setLastSynchVersion
	(@FULLTABLENAME   NVARCHAR(128)
	,@CURRENT_VERSION BIGINT) 
AS
BEGIN
	UPDATE SISWEB_OWNER_STAGING._LAST_SYNCHRONIZATION_VERSIONS
		   SET LAST_SYNCHRONIZATION_VERSION = @CURRENT_VERSION
	WHERE TABLENAME = @FULLTABLENAME;
END;
GO

