BEGIN TRANSACTION;

IF
   EXISTS(SELECT *
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE
				  TABLE_SCHEMA = 'admin'
				  AND TABLE_NAME = 'User'
				  AND COLUMN_NAME = 'catRecID')
   AND NOT EXISTS(SELECT * FROM admin.[User])

BEGIN
	PRINT 'Restore rows from admin.User_backup table to admin.User';

	INSERT INTO admin.[User]
		   (User_ID
		   ,cws
		   ,catRecID
		   ,User_Name
		   ,User_Status
			--,Last_Logon_Time
		   ,Reason
		   ,Affiliation_ID
		   ) 
	SELECT User_ID
		  ,cws
		  ,catRecID
		  ,User_Name
		  ,User_Status
		   --,Last_Logon_Time
		  ,Reason
		  ,Affiliation_ID FROM admin.User_backup;

	DROP TABLE IF EXISTS admin.User_backup;
END;
--ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
GO