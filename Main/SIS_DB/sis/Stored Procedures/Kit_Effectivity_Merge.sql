CREATE PROCEDURE [sis].[Kit_Effectivity_Merge]   (@DEBUG BIT = 'FALSE')
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

        --correcting Range >99999
        UPDATE [KIM].[SIS_KitEffectivity] SET MACHINESNEND = 99999 WHERE MACHINESNEND >99999;
        UPDATE [KIM].[SIS_KitEffectivity] SET ENGINESNEND = 99999 WHERE ENGINESNEND >99999;
        UPDATE [KIM].[SIS_KitEffectivity] SET TQCONVERTORSNEND = 99999 WHERE TQCONVERTORSNEND >99999;
        
        -- Kit Effectivity Column Population

        --kit Effectivity add Prime First
        
        DECLARE @MERGE_RESULTS9_0 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Kit_ID         INT NOT NULL
			);
        MERGE [sis].[Kit_Effectivity] AS target  
            USING (
                select distinct kit.Kit_ID, snp.SerialNumberPrefix_ID,snr.SerialNumberRange_ID , 'MACHINE', null
                from        [KIM].[SIS_KitEffectivity] kit_eff  
                inner join  [sis].[Kit] kit                     on kit.Number = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberPrefix] snp      on snp.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
                inner join  [KIM].[SIS_KitNumbers] kit_src      on kit_src.KITNUMBER = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberRange] snr       on snr.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr.End_Serial_Number = kit_eff.MACHINESNEND
            ) AS source (Kit_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, [Type], Parent_ID)  
            ON (target.Kit_ID = source.Kit_ID 
                and target.SerialNumberPrefix_ID = source.SerialNumberPrefix_ID 
                and target.SerialNumberRange_ID = source.SerialNumberRange_ID
                and target.[Type] = source.[Type]
                and COALESCE(target.Parent_ID,-1) = COALESCE(source.Parent_ID,-1)
               )
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, [Type], Parent_ID)  
                VALUES (source.Kit_ID, source.SerialNumberPrefix_ID, source.SerialNumberRange_ID, source.[Type], source.Parent_ID) 
			OUTPUT 
                $ACTION,
                COALESCE(inserted.Kit_ID, deleted.Kit_ID) Kit_ID
                INTO @MERGE_RESULTS9_0;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS9_0 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS9_0 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Kit_ID
                                                FROM @MERGE_RESULTS9_0 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_Effectivity(PRIME) Columns Modified Rows');

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, @LOGMESSAGE, @MERGED_ROWS);


        -- kit Effectivity Add Captives 
        DECLARE @MERGE_RESULTS9_1 TABLE
			(ACTIONTYPE          NVARCHAR(10)
			,Kit_ID         INT NOT NULL
			);

        BEGIN TRANSACTION;

        MERGE [sis].[Kit_Effectivity] AS target  
            USING (
                select distinct kit.Kit_ID, snp.SerialNumberPrefix_ID,snr.SerialNumberRange_ID , 'ENGINE', sis_kit_eff.Kit_Effectivity_ID
                from        [KIM].[SIS_KitEffectivity] kit_eff
                inner join  [sis].[Kit] kit                         on kit.Number = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberPrefix]  snp         on snp.Serial_Number_Prefix = kit_eff.ENGINEPREFIX
                inner join  [KIM].[SIS_KitNumbers]      kit_src     on kit_src.KITNUMBER = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberRange]   snr         on snr.Start_Serial_Number = kit_eff.ENGINESNBEGIN and snr.End_Serial_Number = kit_eff.ENGINESNEND
                left join   [sis].[SerialNumberPrefix]  snp2        on snp2.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
                left join   [sis].[SerialNumberRange]   snr2        on snr2.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr2.End_Serial_Number = kit_eff.MACHINESNEND
                left join   [sis].[Kit_Effectivity]     sis_kit_eff on sis_kit_eff.Kit_ID = kit.Kit_ID and sis_kit_eff.[Type] = 'MACHINE' and 
                                                                       snp2.SerialNumberPrefix_ID = sis_kit_eff.SerialNumberPrefix_ID and
                                                                       snr2.SerialNumberRange_ID = sis_kit_eff.SerialNumberRange_ID
                 
                UNION
                select distinct kit.Kit_ID, snp.SerialNumberPrefix_ID,snr.SerialNumberRange_ID , 'TQCONVERTOR', sis_kit_eff.Kit_Effectivity_ID
                from        [KIM].[SIS_KitEffectivity]  kit_eff
                inner join  [sis].[Kit]                 kit         on kit.Number = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberPrefix]  snp         on snp.Serial_Number_Prefix = kit_eff.TQCONVERTORPREFIX
                inner join  [KIM].[SIS_KitNumbers]      kit_src     on kit_src.KITNUMBER = kit_eff.KITNUMBER
                inner join  [sis].[SerialNumberRange]   snr         on snr.Start_Serial_Number = kit_eff.TQCONVERTORSNBEGIN and snr.End_Serial_Number = kit_eff.TQCONVERTORSNEND
                left join   [sis].[SerialNumberPrefix]  snp2        on snp2.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
                left join   [sis].[SerialNumberRange]   snr2        on snr2.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr2.End_Serial_Number = kit_eff.MACHINESNEND
                left join   [sis].[Kit_Effectivity]     sis_kit_eff on sis_kit_eff.Kit_ID = kit.Kit_ID and sis_kit_eff.[Type] = 'MACHINE' and 
                                                                       snp2.SerialNumberPrefix_ID = sis_kit_eff.SerialNumberPrefix_ID and
                                                                       snr2.SerialNumberRange_ID = sis_kit_eff.SerialNumberRange_ID

            ) AS source (Kit_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, [Type], Parent_ID)  
            ON (target.Kit_ID = source.Kit_ID 
                and target.SerialNumberPrefix_ID = source.SerialNumberPrefix_ID 
                and target.SerialNumberRange_ID = source.SerialNumberRange_ID
                and target.[Type] = source.[Type]
                and COALESCE(target.Parent_ID,-1) = COALESCE(source.Parent_ID,-1)
               )
            WHEN NOT MATCHED BY TARGET THEN  
                INSERT  (Kit_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, [Type], Parent_ID)  
                VALUES (source.Kit_ID, source.SerialNumberPrefix_ID, source.SerialNumberRange_ID, source.[Type], source.Parent_ID)     
			OUTPUT 
                $ACTION,
                COALESCE(inserted.Kit_ID, deleted.Kit_ID) Kit_ID
                INTO @MERGE_RESULTS9_1;
        
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(
                            @DEBUG = 'TRUE'
                                     ,(SELECT
                                         (SELECT COUNT(*) FROM @MERGE_RESULTS9_1 AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS9_1 AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                        ,(SELECT MR.ACTIONTYPE
                                                ,MR.Kit_ID
                                                FROM @MERGE_RESULTS9_1 AS MR FOR JSON AUTO
                                            ) AS  Modified_Rows FOR JSON PATH
                                        ,WITHOUT_ARRAY_WRAPPER
                                        ),'Kit_Effectivity(CAPTIVE) Columns Modified Rows');

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