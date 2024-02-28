BEGIN TRANSACTION;

IF EXISTS(SELECT *
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE
				  TABLE_SCHEMA = N'admin'
				  AND TABLE_NAME = N'User'
				  AND COLUMN_NAME = N'catReqID')
BEGIN
	PRINT 'Backup rows from admin.User table to admin.User_backup';

	DROP TABLE IF EXISTS admin.User_backup;

	--trying to elude the syntax checker

	EXECUTE sp_executesql N'SELECT U.User_ID
		  ,U.cws
		  ,U.catReqID AS catRecID
		  ,U.User_Name
		  ,U.User_Status
		   --,Last_Logon_Time
		  ,U.Reason
		  ,U.Affiliation_ID
	INTO admin.User_backup
	  FROM admin.[User] U';

/* -- drops and recreates:
sis.admin.User_AccessProfile_Relation: FK_User_AccessProfile_Relation_User
sis.admin.User_Contact: FK_User_Contact_User
sis.admin.User_Group_Relation: FK_User_Group_Relation_User
sis.admin.User_Organization_Relation: FK_User_Organization_Relation_User
*/

	DECLARE @FK_User_AccessProfile_Relation_User BIT = 'FALSE';
	DECLARE @FK_User_Contact_User BIT = 'FALSE';
	DECLARE @FK_User_Group_Relation_User BIT = 'FALSE';
	DECLARE @FK_User_Organization_Relation_User BIT = 'FALSE';

	SELECT @FK_User_AccessProfile_Relation_User = COUNT(*)
	  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	  WHERE
			CONSTRAINT_SCHEMA = N'admin'
			AND CONSTRAINT_NAME = N'FK_User_AccessProfile_Relation_User'
			AND UNIQUE_CONSTRAINT_NAME = N'PK_User';

	SELECT @FK_User_Contact_User = COUNT(*)
	  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	  WHERE
			CONSTRAINT_SCHEMA = N'admin'
			AND CONSTRAINT_NAME = N'FK_User_Contact_User'
			AND UNIQUE_CONSTRAINT_NAME = N'PK_User';

	SELECT @FK_User_Group_Relation_User = COUNT(*)
	  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	  WHERE
			CONSTRAINT_SCHEMA = N'admin'
			AND CONSTRAINT_NAME = N'FK_User_Group_Relation_User'
			AND UNIQUE_CONSTRAINT_NAME = N'PK_User';

	SELECT @FK_User_Organization_Relation_User = COUNT(*)
	  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	  WHERE
			CONSTRAINT_SCHEMA = N'admin'
			AND CONSTRAINT_NAME = N'FK_User_Organization_Relation_User'
			AND UNIQUE_CONSTRAINT_NAME = N'PK_User';

	IF @FK_User_AccessProfile_Relation_User = 'TRUE'
		ALTER TABLE admin.User_AccessProfile_Relation DROP CONSTRAINT FK_User_AccessProfile_Relation_User;

	IF @FK_User_Contact_User = 'TRUE'
		ALTER TABLE admin.User_Contact DROP CONSTRAINT FK_User_Contact_User;

	IF @FK_User_Group_Relation_User = 'TRUE'
		ALTER TABLE admin.User_Group_Relation DROP CONSTRAINT FK_User_Group_Relation_User;

	IF @FK_User_Organization_Relation_User = 'TRUE'
		ALTER TABLE admin.User_Organization_Relation DROP CONSTRAINT FK_User_Organization_Relation_User;

	TRUNCATE TABLE admin.[User];

	IF @FK_User_AccessProfile_Relation_User = 'TRUE'
	BEGIN
		ALTER TABLE admin.User_AccessProfile_Relation
		WITH NOCHECK
		ADD CONSTRAINT FK_User_AccessProfile_Relation_User FOREIGN KEY(User_ID) REFERENCES admin.[User](User_ID);
		ALTER TABLE admin.User_AccessProfile_Relation CHECK CONSTRAINT FK_User_AccessProfile_Relation_User;
	END;

	IF @FK_User_Contact_User = 'TRUE'
	BEGIN
		ALTER TABLE admin.User_Contact
		WITH CHECK
		ADD CONSTRAINT FK_User_Contact_User FOREIGN KEY(User_ID) REFERENCES admin.[User](User_ID);
		ALTER TABLE admin.User_Contact CHECK CONSTRAINT FK_User_Contact_User;
	END;

	IF @FK_User_Group_Relation_User = 'TRUE'
	BEGIN
		ALTER TABLE admin.User_Group_Relation
		WITH NOCHECK
		ADD CONSTRAINT FK_User_Group_Relation_User FOREIGN KEY(User_ID) REFERENCES admin.[User](User_ID);
		ALTER TABLE admin.User_Group_Relation CHECK CONSTRAINT FK_User_Group_Relation_User;
	END;

	IF @FK_User_Organization_Relation_User = 'TRUE'
	BEGIN
		ALTER TABLE admin.User_Organization_Relation
		WITH CHECK
		ADD CONSTRAINT FK_User_Organization_Relation_User FOREIGN KEY(User_ID) REFERENCES admin.[User](User_ID);
		ALTER TABLE admin.User_Organization_Relation CHECK CONSTRAINT FK_User_Organization_Relation_User;
	END;
END;
--ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
GO