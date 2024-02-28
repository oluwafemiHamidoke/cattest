CREATE PROCEDURE [sis].[KitBillOfMaterial_Merge]  (@DEBUG BIT = 'FALSE')
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

        BEGIN TRANSACTION;
        
        DROP TABLE IF EXISTS #Serviceability_Indicator_KBOM;
        Select SERVICEABILITY, Substring(SERVICEABILITY,1,1) indicator
        into #Serviceability_Indicator_KBOM
        from [KIM].[SIS_KitBillOfMaterials]
        group by SERVICEABILITY;

		-- Load KitBillOfMaterial
		DECLARE @MERGE_RESULTS8 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Quantity         VARCHAR(50) NOT NULL
			);
        MERGE [sis].[KitBillOfMaterial] AS target  
            USING (
            select 		kits.Kit_ID,kitComp.KitComponent_ID, max(kbom.QUANTITY), si.indicator
            from        [KIM].[SIS_KitBillOfMaterials] kbom
            inner join  #Serviceability_Indicator_KBOM   si  on si.Serviceability = kbom.Serviceability
            inner join  [sis].[Kit] kits               		 on  kits.Number = kbom.KITNUMBER
            inner join  [sis].[KitComponent] kitComp   		 on  kitComp.Number = kbom.COMPONENT_NUMBER
            inner join  [KIM].[SIS_KitNumbers] kit_src 		 on  kit_src.KITNUMBER = kbom.KITNUMBER
            GROUP BY  kits.Kit_ID, kitComp.KitComponent_ID,si.indicator
            ) AS 
				source (Kit_ID, KitComponent_ID,Quantity,SERVICEABILITY)
				ON (target.Kit_ID = source.Kit_ID and target.KitComponent_ID = source.KitComponent_ID )
            WHEN MATCHED AND  EXISTS(
                SELECT source.Quantity, source.SERVICEABILITY
                EXCEPT
                SELECT target.Quantity, target.Serviceability_Indicator
                ) THEN
                UPDATE SET  Quantity = source.Quantity , Serviceability_Indicator = source.SERVICEABILITY
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID,KitComponent_ID,Quantity, Serviceability_Indicator)
                VALUES (source.Kit_ID, source.KitComponent_ID, source.Quantity, source.SERVICEABILITY)
			WHEN NOT MATCHED BY SOURCE THEN
				DELETE
			OUTPUT 
                $ACTION,
                COALESCE(inserted.Quantity, deleted.Quantity) Quantity
                INTO @MERGE_RESULTS8;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS8 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS8 AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS8 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Quantity
                                                FROM @MERGE_RESULTS8 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'KitBillOfMaterial Modified Rows');

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
        Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL);

	    IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                THROW;
            END

    END CATCH

END