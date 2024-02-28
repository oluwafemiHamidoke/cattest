CREATE PROCEDURE [sis].[Kit_ParentPart_Relation_Merge]  (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@ProcName                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@ProcessID                     UNIQUEIDENTIFIER = NEWID()
			   ,@DEFAULT_ORGCODE			  VARCHAR(12) 	   = SISWEB_OWNER_STAGING._getDefaultORGCODE();

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

        BEGIN TRANSACTION;
        -- Load relation tables --

		-- Load Kit_ParentPart_Relation
        DECLARE @MERGE_RESULTS7 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,set_type         VARCHAR(50) NOT NULL
			);

        MERGE [sis].[Kit_ParentPart_Relation] AS target  
            USING 
			(
            select kits.Kit_ID, p.Part_ID, max(kpp.COMPONENTSETTYPE)
            from        [KIM].[SIS_KitParentParts] kpp
            inner join  [sis].[Kit] kits                on kits.Number       = kpp.KITNUMBER
            inner join  [sis].[Part] p                  on kpp.PARENTPART    = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE
            inner join  [KIM].[SIS_KitNumbers] kit_src  on kit_src.KITNUMBER = kpp.KITNUMBER    --added this to remove mapping for which KITNumber is not present in master
			WHERE kpp.PARENTPART <> '' -- to exclude null parent parts.
            GROUP BY  kits.Kit_ID, p.Part_ID
            )   
			AS source (kit_id, part_id,settype)  
            ON  (target.Kit_ID = source.kit_id and target.ParentPart_ID = source.part_id)
            WHEN MATCHED 
                AND EXISTS
				(
                    SELECT source.settype
                    EXCEPT
                    SELECT target.SetType
                ) 
				THEN 
                UPDATE SET  SetType = source.settype 
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID, ParentPart_ID, SetType)
                VALUES (source.kit_id, source.part_id, source.settype)
			WHEN NOT MATCHED BY SOURCE THEN
				DELETE
			OUTPUT 
                $ACTION,
                COALESCE(inserted.SetType, deleted.SetType) SetType
                INTO @MERGE_RESULTS7;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS7 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS7 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS7 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.set_type
                                                FROM @MERGE_RESULTS7 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_ParentPart_Relation Modified Rows');

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