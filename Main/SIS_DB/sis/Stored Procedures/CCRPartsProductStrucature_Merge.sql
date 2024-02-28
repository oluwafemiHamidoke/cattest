
-- =============================================
-- Author:      Madhukar Bhandari
-- Create Date: 20181002
-- Description: Merges a complex low performing query into [sis].[CCRPartsProductStructure] for SIS2 to access
-- =============================================
CREATE PROCEDURE [sis].[CCRPartsProductStructure_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY

        DECLARE @MERGED_ROWS                   INT              = 0
            ,@LOGMESSAGE                    VARCHAR(MAX);

        Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        Declare @ProcessID uniqueidentifier = NewID()

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        MERGE [sis].[CCRPartsProductStructure] AS x
            USING (

                select 
                    distinct
                    m.Media_Number,  
                    snp.Serial_Number_Prefix,
                    ms.IESystemControlNumber,
                    part.Part_Number,
                    part.Part_ID,
                    ps.ParentProductStructure_ID  as PARENTPRODUCTSTRUCTUREID,
                    ps.ProductStructure_ID  as PRODUCTSTRUCTUREID,
                    snr.Start_Serial_Number,
                    snr.End_Serial_Number,
                    ms.CCR_Indicator
                    from sis.ProductStructure_IEPart_Relation psiepart
                    join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = psiepart.SerialNumberPrefix_ID  --2703
                    join sis.SerialNumberRange snr on snr.SerialNumberRange_ID = psiepart.SerialNumberRange_ID   --2458
                    join sis.IEPart iepart on iepart.IEPart_ID = psiepart.IEPart_ID --9100900
                    join sis.Media m on m.Media_ID = psiepart.Media_ID
                    join sis.MediaSection msec on msec.Media_ID = m.Media_ID --125893263
                    join sis_shadow.MediaSequence ms on ms.MediaSection_ID = msec.MediaSection_ID and ms.IEPart_ID = iepart.IEPart_ID  --600276
                    join sis.ProductStructure ps on ps.ProductStructure_ID = psiepart.ProductStructure_ID --9100900
                    join sis.Part part on part.Part_ID = iepart.Part_ID
            ) AS s
            ON (    s.[Media_Number]				     = x.[Media_Number]				
                and s.[Serial_Number_Prefix]		 = x.[Serial_Number_Prefix]		
                and s.[IESystemControlNumber]		 = x.[IESystemControlNumber]		
                and s.[Part_Number]					 = x.[Part_Number]				
                and s.[Part_ID]				 		 = x.[Part_ID]				 	
                and s.[PARENTPRODUCTSTRUCTUREID]	 = x.[PARENTPRODUCTSTRUCTUREID]	
                and s.[PRODUCTSTRUCTUREID]			 = x.[PRODUCTSTRUCTUREID]		
                and s.[Start_Serial_Number]			 = x.[Start_Serial_Number]		
                and s.[End_Serial_Number]			 = x.[End_Serial_Number]			
                and s.[CCR_Indicator]				 = x.[CCR_Indicator]		
            )
            WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([Media_Number],[Serial_Number_Prefix],[IESystemControlNumber],[Part_Number],[Part_ID] ,[PARENTPRODUCTSTRUCTUREID],[PRODUCTSTRUCTUREID],[Start_Serial_Number],[End_Serial_Number],[CCR_Indicator])
                VALUES (s.[Media_Number],s.[Serial_Number_Prefix],s.[IESystemControlNumber],s.[Part_Number],s.[Part_ID] ,s.[PARENTPRODUCTSTRUCTUREID],s.[PRODUCTSTRUCTUREID],s.[Start_Serial_Number],s.[End_Serial_Number],s.[CCR_Indicator])
            WHEN NOT MATCHED BY SOURCE
            THEN
                DELETE;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS sis.CCRPartsProductStructure with fullscan

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END
