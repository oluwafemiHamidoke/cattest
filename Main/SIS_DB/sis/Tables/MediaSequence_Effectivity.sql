CREATE TABLE sis.MediaSequence_Effectivity
	(MediaSequence_ID      INT NOT NULL
	,SerialNumberPrefix_ID INT NOT NULL
	,SerialNumberRange_ID  INT NOT NULL
	,SerialNumberPrefix_Type CHAR (1) DEFAULT ('P') NOT NULL
	,[LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE())
	,CONSTRAINT PK_MediaSequence_Effectivity PRIMARY KEY CLUSTERED(MediaSequence_ID ASC,SerialNumberPrefix_ID ASC,SerialNumberRange_ID ASC)
	,CONSTRAINT FK_MediaSequence_Effectivity_MediaSequence FOREIGN KEY(MediaSequence_ID) REFERENCES sis.MediaSequence_Base(MediaSequence_ID)
	,CONSTRAINT FK_MediaSequence_Effectivity_SerialNumberPrefix FOREIGN KEY(SerialNumberPrefix_ID) REFERENCES sis.SerialNumberPrefix(SerialNumberPrefix_ID)
	,CONSTRAINT FK_MediaSequence_Effectivity_SerialNumberRange FOREIGN KEY(SerialNumberRange_ID) REFERENCES sis.SerialNumberRange(SerialNumberRange_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'was [PartsManualSequence_Effectivity], https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence_Effectivity'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
Create nonclustered index IX_MediaSequence_Effectivity_SerialNumberPrefix_ID on sis.MediaSequence_Effectivity (SerialNumberPrefix_ID)  ;
GO
Create nonclustered index IX_MediaSequence_Effectivity_SerialNumberRange_ID on sis.MediaSequence_Effectivity (SerialNumberRange_ID)  ;