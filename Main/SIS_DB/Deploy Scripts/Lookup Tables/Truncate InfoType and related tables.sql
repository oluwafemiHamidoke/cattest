BEGIN TRANSACTION;

IF EXISTS(SELECT *
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE
				  TABLE_SCHEMA = 'sis'
				  AND TABLE_NAME = 'InfoType'
				  AND COLUMN_NAME = 'InfoTypeID')
BEGIN
	PRINT 'Truncating Lookup Table [sis].[InfoType] and dependent tables';

	ALTER TABLE sis.InfoType_Translation DROP CONSTRAINT FK_InfoType_Translation_InfoType;
	ALTER TABLE sis.Media_InfoType_Relation DROP CONSTRAINT FK_Media_InfoType_Relation_InfoType;
	ALTER TABLE sis.IE_InfoType_Relation DROP CONSTRAINT FK_IE_InfoType_Relation_InfoType;
	TRUNCATE TABLE sis.IE_InfoType_Relation;
	TRUNCATE TABLE sis.InfoType_Translation;
	TRUNCATE TABLE sis.Media_InfoType_Relation;
	TRUNCATE TABLE sis.InfoType;
	TRUNCATE TABLE sis_stage.IE_InfoType_Relation;
	TRUNCATE TABLE sis_stage.InfoType_Translation;
	TRUNCATE TABLE sis_stage.Media_InfoType_Relation;
	TRUNCATE TABLE sis_stage.InfoType;
	TRUNCATE TABLE sis_stage.IE_InfoType_Relation_Diff;
	TRUNCATE TABLE sis_stage.InfoType_Translation_Diff;
	TRUNCATE TABLE sis_stage.InfoType_Diff;
	TRUNCATE TABLE sis_stage.InfoType_Key;

	ALTER TABLE sis.InfoType_Translation
	WITH CHECK
	ADD CONSTRAINT FK_InfoType_Translation_InfoType FOREIGN KEY(InfoType_ID) REFERENCES sis.InfoType(InfoType_ID);
	ALTER TABLE sis.InfoType_Translation CHECK CONSTRAINT FK_InfoType_Translation_InfoType;

	ALTER TABLE sis.Media_InfoType_Relation
	WITH CHECK
	ADD CONSTRAINT FK_Media_InfoType_Relation_InfoType FOREIGN KEY(InfoType_ID) REFERENCES sis.InfoType(InfoType_ID);
	ALTER TABLE sis.Media_InfoType_Relation CHECK CONSTRAINT FK_Media_InfoType_Relation_InfoType;

	ALTER TABLE sis.IE_InfoType_Relation
	WITH CHECK
	ADD CONSTRAINT FK_IE_InfoType_Relation_InfoType FOREIGN KEY(InfoType_ID) REFERENCES sis.InfoType(InfoType_ID);
	ALTER TABLE sis.IE_InfoType_Relation CHECK CONSTRAINT FK_IE_InfoType_Relation_InfoType;
END;
--ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
GO