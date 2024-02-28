CREATE PROCEDURE [sis].[KitCategory_Merge]	 (@DEBUG BIT = 'FALSE')
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


       -- Load KitCategory
        -- merging only Main Categories
        DECLARE @MERGE_RESULTS3 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Name         VARCHAR(50) NOT NULL
			);

        BEGIN TRANSACTION;
        
        MERGE [sis].[KitCategory] AS target
            USING (
                select old_kit.PRIMARYCATEGORY,NULL parent_category_name from [KIM].SIS_KitNumbers old_kit 
                where old_kit.PRIMARYCATEGORY is not null and UPPER(TRIM(old_kit.PRIMARYCATEGORY)) <> 'UNKNOWN'
                group by old_kit.PRIMARYCATEGORY
                union
                select old_kit.SECONDARYCATEGORY,NULL from [KIM].SIS_KitNumbers old_kit 
                where old_kit.SECONDARYCATEGORY is not null and UPPER(TRIM(old_kit.SECONDARYCATEGORY)) <> 'UNKNOWN'
                group by old_kit.SECONDARYCATEGORY
            ) AS source (category_name,parent_category_name)
            ON (target.Name = source.category_name )
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Name)
                VALUES (source.category_name)
            OUTPUT 
                $ACTION,
                COALESCE(inserted.Name, deleted.Name) KitCategory_Name
                INTO @MERGE_RESULTS3;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS3 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS3 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS3 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Name
                                                FROM @MERGE_RESULTS3 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'KitCategory Modified Rows');

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, @LOGMESSAGE, @MERGED_ROWS);


        -- Load Kit Sub Categories
        -- main Categories are loaded in previous step, will ensure, all subcategories will find Parent_ID
        
        DECLARE @MERGE_RESULTS4 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Name         VARCHAR(50) NOT NULL
			);

        MERGE [sis].[KitCategory] AS target
            USING (
                Select tab.category_name, siskit.KitCategory_ID Parent_ID From (
					Select old_kit.PRIMARYSUBCATEGORY category_name , old_kit.PRIMARYCATEGORY parent_category_name 
					from [KIM].SIS_KitNumbers old_kit 
					where old_kit.PRIMARYSUBCATEGORY is not null group by old_kit.PRIMARYSUBCATEGORY,old_kit.PRIMARYCATEGORY
					union
					Select old_kit.SECONDARYSUBCATEGORY ,old_kit.SECONDARYCATEGORY parent_category_name from [KIM].SIS_KitNumbers old_kit
					where old_kit.SECONDARYSUBCATEGORY is not null group by old_kit.SECONDARYSUBCATEGORY,old_kit.SECONDARYCATEGORY
				)tab inner join [sis].[KitCategory] siskit on siskit.Name = tab.parent_category_name and siskit.Parent_ID is null
                where UPPER(TRIM(tab.category_name)) <> 'UNKNOWN'
            ) AS source (category_name,parent_id)
            ON (target.Name = source.category_name 
                and
                target.Parent_ID = source.parent_id
                )
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Name,Parent_ID)
                VALUES (source.category_name,source.parent_id)
            OUTPUT 
                $ACTION,
                COALESCE(inserted.Name, deleted.Name) KitCategory_Name
                INTO @MERGE_RESULTS4;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS4 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS4 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS4 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Name
                                                FROM @MERGE_RESULTS4 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'KitCategory Modified Rows');

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