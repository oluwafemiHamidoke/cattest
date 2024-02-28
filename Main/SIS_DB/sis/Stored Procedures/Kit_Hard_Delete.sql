CREATE PROCEDURE [sis].[Kit_Hard_Delete] 
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
        
        -- Delete from  KitCategory for SubCategories
        DELETE category_target
            FROM [sis].[KitCategory] category_target
            inner join  [sis].[KitCategory] category_target2 on category_target.Parent_ID is not Null and category_target.Parent_ID = category_target2.KitCategory_ID
            LEFT JOIN   
                (SELECT PRIMARYSUBCATEGORY,PRIMARYCATEGORY from [KIM].[SIS_KitNumbers] where UPPER(TRIM(PRIMARYSUBCATEGORY)) <> 'UNKNOWN'  group by PRIMARYSUBCATEGORY,PRIMARYCATEGORY
                    union
                    SELECT SECONDARYSUBCATEGORY,SECONDARYCATEGORY from [KIM].[SIS_KitNumbers] where UPPER(TRIM(SECONDARYSUBCATEGORY)) <> 'UNKNOWN' group by SECONDARYSUBCATEGORY,SECONDARYCATEGORY
                )
             category_source 
                ON category_source.PRIMARYSUBCATEGORY = category_target.Name and category_source.PRIMARYCATEGORY = category_target2.Name
            WHERE category_source.PRIMARYSUBCATEGORY is NULL and category_target.Parent_ID is not null;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitPrimarySecondarySubCategory  rows', @@ROWCOUNT);
        
        -- Delete from KitCategory
        DELETE category_target
            FROM [sis].[KitCategory] category_target
            left join [sis].[KitCategory] category2  on category_target.KitCategory_ID = category2.Parent_ID --and category_target.Parent_ID is null
            LEFT JOIN 
                (
				SELECT PRIMARYCATEGORY from [KIM].[SIS_KitNumbers] where UPPER(TRIM(PRIMARYCATEGORY)) <> 'UNKNOWN'   group by PRIMARYCATEGORY
                    union
                SELECT SECONDARYCATEGORY from [KIM].[SIS_KitNumbers] where UPPER(TRIM(SECONDARYCATEGORY)) <> 'UNKNOWN'   group by SECONDARYCATEGORY
                )
            category_source ON category_source.PRIMARYCATEGORY = category_target.Name 
            WHERE category_source.PRIMARYCATEGORY is NULL and category_target.Parent_ID is Null and category2.Parent_ID is Null;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitPrimarySecondaryCategory  rows', @@ROWCOUNT);
        
        -- delete from Kit_Effectivity
          -- delete without type Kit_effectivity
          delete from [sis].[Kit_Effectivity] where [Type] is null;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows where Type is NULL', @@ROWCOUNT);

          -- delete Captives
            
         delete sis_ke
            from [KIM].[SIS_KitEffectivity] kit_eff 
         inner join  [KIM].[SIS_KitNumbers] kit_src     on kit_src.KITNUMBER = kit_eff.KITNUMBER
         inner join [sis].[Kit] kit                     on kit.Number = kit_eff.KITNUMBER
         inner join [sis].[SerialNumberPrefix] snp      on (snp.Serial_Number_Prefix = kit_eff.TQCONVERTORPREFIX)
         inner join  [sis].[SerialNumberRange] snr      on (snr.Start_Serial_Number = kit_eff.TQCONVERTORSNBEGIN 
															and snr.End_Serial_Number = kit_eff.TQCONVERTORSNEND)
															
         right join [sis].[Kit_Effectivity] sis_ke		on sis_ke.Kit_ID = kit.Kit_ID and sis_ke.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
                                                            and sis_ke.SerialNumberRange_ID = snr.SerialNumberRange_ID
         where kit_eff.KITNUMBER is null and sis_ke.[Type] = 'TQCONVERTOR';

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows for TQCONVERTOR', @@ROWCOUNT);

         delete sis_ke
            from [KIM].[SIS_KitEffectivity] kit_eff 
         inner join  [KIM].[SIS_KitNumbers] kit_src     on kit_src.KITNUMBER = kit_eff.KITNUMBER
         inner join [sis].[Kit] kit                     on kit.Number = kit_eff.KITNUMBER
         inner join [sis].[SerialNumberPrefix] snp      on (snp.Serial_Number_Prefix = kit_eff.ENGINEPREFIX )
         inner join  [sis].[SerialNumberRange] snr      on (snr.Start_Serial_Number = kit_eff.ENGINESNBEGIN 
																and snr.End_Serial_Number = kit_eff.ENGINESNEND) 
         right join [sis].[Kit_Effectivity] sis_ke		on sis_ke.Kit_ID = kit.Kit_ID and sis_ke.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
                                                            and sis_ke.SerialNumberRange_ID = snr.SerialNumberRange_ID
         where kit_eff.KITNUMBER is null and sis_ke.[Type] = 'ENGINE';

		 Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows for ENGINE', @@ROWCOUNT);

		 -- delete Captive for which Primes are to be deleted

		delete sis_ke_TQ
		from [sis].[Kit_Effectivity] sis_ke_TQ
		inner join (
			select sis_ke_captive.Kit_Effectivity_ID  
				from [sis].[Kit_Effectivity] sis_ke_captive
				inner join (
					 select sis_ke.Kit_Effectivity_ID
					 from [KIM].[SIS_KitEffectivity] kit_eff 
					 inner join  [KIM].[SIS_KitNumbers] kit_src      on kit_src.KITNUMBER = kit_eff.KITNUMBER
					 inner join [sis].[Kit] kit  on kit.Number = kit_eff.KITNUMBER
					 inner join [sis].[SerialNumberPrefix] snp      on snp.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
					 inner join  [sis].[SerialNumberRange] snr       on snr.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr.End_Serial_Number = kit_eff.MACHINESNEND
					 right join [sis].[Kit_Effectivity] sis_ke		on sis_ke.Kit_ID = kit.Kit_ID and sis_ke.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
					 and sis_ke.SerialNumberRange_ID = snr.SerialNumberRange_ID
					 where kit_eff.KITNUMBER is null and sis_ke.[Type] = 'MACHINE'
					) to_be_deleted_primes 
				on to_be_deleted_primes.Kit_Effectivity_ID= sis_ke_captive.Parent_ID 
				where sis_ke_captive.[Type] in ( 'ENGINE','TQCONVERTOR')
			) sis_ke_engine
			on sis_ke_engine.Kit_Effectivity_ID = sis_ke_TQ.Parent_ID
				where sis_ke_TQ.[Type]  ='TQCONVERTOR'

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows for TQCONVERTOR for which Primes are to be deleted', @@ROWCOUNT);

		 delete sis_ke_captive 
		 from [sis].[Kit_Effectivity] sis_ke_captive
			inner join (
			 select sis_ke.Kit_Effectivity_ID
			 from [KIM].[SIS_KitEffectivity] kit_eff 
			 inner join  [KIM].[SIS_KitNumbers] kit_src      on kit_src.KITNUMBER = kit_eff.KITNUMBER
			 inner join [sis].[Kit] kit  on kit.Number = kit_eff.KITNUMBER
			 inner join [sis].[SerialNumberPrefix] snp      on snp.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
			 inner join  [sis].[SerialNumberRange] snr       on snr.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr.End_Serial_Number = kit_eff.MACHINESNEND
			 right join [sis].[Kit_Effectivity] sis_ke		on sis_ke.Kit_ID = kit.Kit_ID and sis_ke.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
			 and sis_ke.SerialNumberRange_ID = snr.SerialNumberRange_ID
			 where kit_eff.KITNUMBER is null and sis_ke.[Type] = 'MACHINE'
			) to_be_deleted_primes on to_be_deleted_primes.Kit_Effectivity_ID= sis_ke_captive.Parent_ID 
			where sis_ke_captive.[Type]  in ('ENGINE','TQCONVERTOR')
		
		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows for ENGINE+TQCONVERTOR for which Primes are to be deleted', @@ROWCOUNT);
            --delete Prime
         delete sis_ke
         from [KIM].[SIS_KitEffectivity] kit_eff 
         inner join  [KIM].[SIS_KitNumbers] kit_src      on kit_src.KITNUMBER = kit_eff.KITNUMBER
         inner join [sis].[Kit] kit  on kit.Number = kit_eff.KITNUMBER
         inner join [sis].[SerialNumberPrefix] snp      on snp.Serial_Number_Prefix = kit_eff.MACHINEPREFIX
         inner join  [sis].[SerialNumberRange] snr       on snr.Start_Serial_Number = kit_eff.MACHINESNBEGIN and snr.End_Serial_Number = kit_eff.MACHINESNEND
         right join [sis].[Kit_Effectivity] sis_ke		on sis_ke.Kit_ID = kit.Kit_ID and sis_ke.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
         and sis_ke.SerialNumberRange_ID = snr.SerialNumberRange_ID
         where kit_eff.KITNUMBER is null and sis_ke.[Type] = 'MACHINE'

		 Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitEFffectivity rows for Machine', @@ROWCOUNT);

        -- delete from master tables 
		DELETE component_target
            FROM [sis].[KitComponent] component_target
            LEFT JOIN [KIM].[SIS_KitBillOfMaterials] component_source ON component_source.COMPONENT_NUMBER = component_target.Number
            WHERE component_source.COMPONENT_NUMBER is NULL;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitComponent rows', @@ROWCOUNT);
        
        DELETE kits_target
            FROM [sis].[Kit] kits_target
            LEFT JOIN [KIM].[SIS_KitNumbers] kit_source ON kit_source.KITNUMBER = kits_target.Number
            WHERE kit_source.KITNUMBER is NULL;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted Kit rows', @@ROWCOUNT);

        -- Delete from KitType
         DELETE kittype_target
            FROM [sis].[KitType] kittype_target
            LEFT JOIN [KIM].[SIS_KitNumbers] kittype_source ON kittype_source.KITTYPE = kittype_target.Name and UPPER(TRIM(kittype_source.KITTYPE)) <> 'UNKNOWN'
            WHERE kittype_source.KITTYPE is NULL;

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted KitType rows', @@ROWCOUNT);

		Update STATISTICS sis.Kit with fullscan 
        Update STATISTICS sis.Kit_Category_Relation with fullscan 
        Update STATISTICS sis.Kit_ParentPart_Relation with fullscan 
        Update STATISTICS sis.Kit_Type_Relation with fullscan 
        Update STATISTICS sis.KitBillOfMaterial with fullscan 
        Update STATISTICS sis.KitCategory with fullscan 
        Update STATISTICS sis.KitComponent with fullscan 
        Update STATISTICS sis.KitType with fullscan 
		Update STATISTICS sis.Kit_Effectivity with fullscan
		Update STATISTICS sis.Kit_ImageIdentifier with fullscan

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Statistics Updated', NULL)

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

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