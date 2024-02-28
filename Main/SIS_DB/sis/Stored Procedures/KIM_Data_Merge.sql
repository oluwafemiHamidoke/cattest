-- =============================================
-- Author:      Ajit Y. Junghare
-- Create Date: 20200806
-- Description: Copy data From [KIM] Schema to [SIS]
-- Updated 08/17/2021 by Krishna Rudraraju to add logic to check record count before merging (14340). 
-- Modified By: Kishor Padmanabhan
-- Modified At: 20221003
-- Associated WI: 23063 
-- Modified 08242023 by Krishna Rudraraju. Associated Work Item (30579)
-- =============================================
CREATE PROCEDURE [sis].[KIM_data_Merge]
(@FORCE_LOAD BIT = 'FALSE',
@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @KIM_SIS_KITNUMBERS            DECIMAL(12,3)    = 0
               ,@SIS_KIT_ROWCOUNT			   DECIMAL(12,3)    = 0
               ,@MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0                                                                                                                                                                                              
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@ProcName                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@ProcessID                     UNIQUEIDENTIFIER = NEWID()
               
        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

	                        
	IF @FORCE_LOAD = 'FALSE'
    BEGIN
		SELECT @KIM_SIS_KITNUMBERS = COUNT_BIG(*) FROM  [KIM].SIS_KitNumbers;
        SELECT @SIS_KIT_ROWCOUNT = COUNT_BIG(*) FROM [sis].[Kit];
        SELECT @MODIFIED_ROWS_PERCENTAGE = (@KIM_SIS_KITNUMBERS - @SIS_KIT_ROWCOUNT) / @SIS_KIT_ROWCOUNT;
		IF @DEBUG = 'TRUE'
          BEGIN
             PRINT FORMATMESSAGE('@KIM_SIS_KITNUMBERS=%s',FORMAT(@KIM_SIS_KITNUMBERS,'G','en-us'));
             PRINT FORMATMESSAGE('@SIS_KIT_ROWCOUNT=%s',FORMAT(@SIS_KIT_ROWCOUNT,'G','en-us'));
             PRINT FORMATMESSAGE('@MODIFIED_ROWS_PERCENTAGE=%s',FORMAT(@MODIFIED_ROWS_PERCENTAGE,'P','en-us'));
          END;
        END; 

	IF
        @FORCE_LOAD = 1
        OR @MODIFIED_ROWS_PERCENTAGE BETWEEN-0.10 AND 0.10

        BEGIN

		SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');;

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, @LOGMESSAGE, NULL)


        EXEC [sis].[Kit_Merge];
		EXEC [sis].[KitComponent_Merge] 
		EXEC [sis].[KitCategory_Merge]
		EXEC [sis].[KitType_Merge]	
		EXEC [sis].[Kit_ParentPart_Relation_Merge] 
		EXEC [sis].[KitBillOfMaterial_Merge] 
		EXEC [sis].[Kit_Effectivity_Merge] 
		EXEC [sis].[Kit_Category_Relation_Merge] 
		EXEC [sis].[Kit_Type_Relation_Merge] 
		EXEC [sis].[Kit_ImageIdentifier_Merge] 
        EXEC [sis].[Kit_Media_Relation_Merge]        
		EXEC [sis].[Kit_Hard_Delete]

		END
		ELSE
        BEGIN
        
		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'Skipping load: Row difference outside range (±10%)', NULL)
		
		END;

		Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

    END TRY

    BEGIN CATCH 

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
        Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)
        
    END CATCH

END