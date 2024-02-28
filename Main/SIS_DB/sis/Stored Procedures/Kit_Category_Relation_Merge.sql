CREATE PROCEDURE [sis].[Kit_Category_Relation_Merge] (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@ProcName                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@ProcessID                     UNIQUEIDENTIFIER = NEWID()


        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)


        -- Load CategoryID-KitID Table
        DECLARE @MERGE_RESULTS10 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Kit_ID         INT NOT NULL
			);

        BEGIN TRANSACTION;

        MERGE [sis].[Kit_Category_Relation] AS target  
            USING (
                select kit.Kit_ID,KitCat.KitCategory_ID, 'P' Type
                from        [KIM].[SIS_KitNumbers] kit_old
                inner join  [sis].[Kit] kit             on kit.Number = kit_old.KITNUMBER
                inner join  [sis].[KitCategory] KitCat  on kit_old.PRIMARYCATEGORY = KitCat.[Name] and UPPER(TRIM(KitCat.[Name])) <> 'UNKNOWN'
                where KitCat.Parent_ID is null and (kit_old.PRIMARYSUBCATEGORY is null or UPPER(TRIM(kit_old.PRIMARYSUBCATEGORY)) = 'UNKNOWN')
                union
                select kit.Kit_ID,KitCat.KitCategory_ID, 'S'
                from        [KIM].[SIS_KitNumbers] kit_old
                inner join  [sis].[Kit] kit             on kit.Number = kit_old.KITNUMBER
                inner join  [sis].[KitCategory] KitCat  on kit_old.SECONDARYCATEGORY = KitCat.[Name] and UPPER(TRIM(KitCat.[Name])) <> 'UNKNOWN'
                where KitCat.Parent_ID is null and (kit_old.SECONDARYSUBCATEGORY is null or UPPER(TRIM(kit_old.SECONDARYSUBCATEGORY)) = 'UNKNOWN')
                union 
                select kit.Kit_ID, KitCat.KitCategory_ID, 'P'
                from        [KIM].[SIS_KitNumbers] kit_old
                inner join  [sis].[Kit] kit             on kit.Number = kit_old.KITNUMBER
                inner join  [sis].[KitCategory] KitCat  on kit_old.PRIMARYSUBCATEGORY = KitCat.[Name] and UPPER(TRIM(KitCat.[Name])) <> 'UNKNOWN'
                inner join	[sis].[KitCategory] KitCat2 on KitCat.Parent_ID = KitCat2.KitCategory_ID and kit_old.PRIMARYCATEGORY = KitCat2.[Name] and UPPER(TRIM(KitCat2.[Name])) <> 'UNKNOWN'
                union 
                select kit.Kit_ID, KitCat.KitCategory_ID, 'S'
                from        [KIM].[SIS_KitNumbers] kit_old
                inner join  [sis].[Kit] kit             on kit.Number = kit_old.KITNUMBER
                inner join  [sis].[KitCategory] KitCat  on kit_old.SECONDARYSUBCATEGORY = KitCat.[Name] and UPPER(TRIM(KitCat.[Name])) <> 'UNKNOWN'
                inner join	[sis].[KitCategory] KitCat2 on KitCat.Parent_ID = KitCat2.KitCategory_ID and kit_old.PRIMARYCATEGORY = KitCat2.[Name] and UPPER(TRIM(KitCat2.[Name])) <> 'UNKNOWN'

            ) AS source (Kit_ID, KitCategory_ID, [Type])  
            ON (target.Kit_ID = source.Kit_ID 
                and target.KitCategory_ID = source.KitCategory_ID and target.[Type] = source.[Type])
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID, KitCategory_ID,[Type])  
                VALUES (source.Kit_ID, source.KitCategory_ID,source.[Type])  
			WHEN NOT MATCHED BY SOURCE THEN
				DELETE
			OUTPUT 
                $ACTION,
                COALESCE(inserted.Kit_ID, deleted.Kit_ID) Kit_ID
                INTO @MERGE_RESULTS10;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS10 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS10 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Kit_ID
                                                FROM @MERGE_RESULTS10 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_Category_Relation Modified Rows');

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, @LOGMESSAGE, @MERGED_ROWS);

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL);

        COMMIT;

    END TRY

    BEGIN CATCH 

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

        
	    IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                THROW;
            END

    END CATCH

END