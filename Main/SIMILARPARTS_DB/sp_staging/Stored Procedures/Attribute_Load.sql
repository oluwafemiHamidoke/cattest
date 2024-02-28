CREATE PROCEDURE [sp_staging].[Attribute_Load]
(@DEBUG  BIT = 0 ) -- DEBUG off (0)
AS
BEGIN
    SET NOCOUNT ON
  
    BEGIN TRY    

      DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
            ,@ProcessID UNIQUEIDENTIFIER = NEWID()
            ,@MERGED_ROWS  INT  = 0
            ,@LOGMESSAGE VARCHAR(MAX)
            ,@LastRefresh_Date DATETIME2(7);

      DECLARE @MERGE_RESULTS TABLE
      (
        ACTIONTYPE         NVARCHAR(10)
        ,Attribute_Number         VARCHAR(20) NOT NULL
        ,Attribute_Name   VARCHAR(100) NOT NULL
      );

    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

    SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM [sp].[Attribute];

    ;WITH AttributeCTE
    AS
    (
    SELECT DISTINCT
      ATTR.ID AS Attribute_Number,
      ATTR.NAME AS Attribute_Name,
      CASE 
        WHEN LOV.List_Of_Values_ID IS NOT NULL THEN 'FormatKeyLov'
        WHEN LOV.List_Of_Values_ID IS NULL AND TYPE_ID = 1 THEN 'FormatString'
        WHEN LOV.List_Of_Values_ID IS NULL AND TYPE_ID = 2 THEN 'FormatInteger'
        WHEN LOV.List_Of_Values_ID IS NULL AND TYPE_ID = 3 THEN 'FormatFloat'
      END AS Attribute_Format
      ,UNIT_METRIC AS Attribute_Unit
      ,CASE 
        WHEN	FORMAT_METRIC IS NOT NULL  AND 
            TYPE_ID = 2  AND 
            LOWER(FORMAT_METRIC) NOT LIKE 'int%(%,%)%' AND
            LOWER(FORMAT_METRIC) LIKE 'int%(%)%'
        THEN -- take the value from interger(10)
          SUBSTRING	(FORMAT_METRIC, 
                CHARINDEX('(', FORMAT_METRIC)+1, (
                CHARINDEX(')',FORMAT_METRIC)-CHARINDEX('(', FORMAT_METRIC)-1)
              )
        WHEN	FORMAT_METRIC IS NOT NULL AND
            TYPE_ID = 2 AND 
            LOWER(FORMAT_METRIC)  LIKE 'int%(%,%)%' 
        THEN -- take the value from interger(10,positive)
          REVERSE(
            PARSENAME(
              REPLACE(
                REVERSE(
                    SUBSTRING	(FORMAT_METRIC, 
                          CHARINDEX('(', FORMAT_METRIC)+1, 
                          (CHARINDEX(')',FORMAT_METRIC)-CHARINDEX('(', FORMAT_METRIC)-1)
                          )
                    ), ',', '.'), 1))
        ELSE NULL 
      END AS FormatInteger_scale
      ,CASE 
        WHEN	FORMAT_METRIC IS NOT NULL AND
            TYPE_ID = 1 AND
            LOWER(FORMAT_METRIC) LIKE 'string%(%)%' 
        THEN --take value from string(20)
          SUBSTRING	(FORMAT_METRIC, 
                  CHARINDEX('(', FORMAT_METRIC)+1, (
                  CHARINDEX(')',FORMAT_METRIC)-CHARINDEX('(', FORMAT_METRIC)-1)
                )
      ELSE NULL END AS FormatString_scale
      ,NULL AS FormatFloat_sign
      ,CASE 
        WHEN	FORMAT_METRIC IS NOT NULL AND
            TYPE_ID = 3 AND
            LOWER(FORMAT_METRIC) LIKE 'real%(%)%' 
        THEN --take precision value from REAL(10,20)
          REVERSE(
            PARSENAME(
              REPLACE(
                REVERSE(
                    SUBSTRING	(FORMAT_METRIC, 
                          CHARINDEX('(', FORMAT_METRIC)+1, 
                          (CHARINDEX(')',FORMAT_METRIC)-CHARINDEX('(', FORMAT_METRIC)-1)
                          )
                    ), ',', '.'), 1))
        ELSE NULL 
      END AS FormatFloat_precision
      ,CASE 
        WHEN	FORMAT_METRIC IS NOT NULL AND
            TYPE_ID = 3 AND
            LOWER(FORMAT_METRIC) LIKE 'real%(%)%'
        THEN --take scale value from REAL(10,20)
          REVERSE(
              PARSENAME(
                    REPLACE(
                          REVERSE(
                      SUBSTRING	(FORMAT_METRIC, 
                            CHARINDEX('(', FORMAT_METRIC)+1, 
                            (CHARINDEX(')',FORMAT_METRIC)-CHARINDEX('(', FORMAT_METRIC)-1)
                            )
                      ), ',', '.'), 2
                  )
              )
        ELSE NULL 
      END  AS FormatFloat_scale
      ,LOV.List_Of_Values_ID
      ,ATTR.REFRESHED_TS AS LastModified_Date
    FROM [sp_staging].[ATTRIBUTE] ATTR
    INNER JOIN [sp_staging].[CLASS_ATTRIBUTES] C ON ATTR.ID = C.ATTRIBUTE_ID
    LEFT JOIN sp.List_Of_Values LOV ON ATTR.ID = LOV.List_Of_Values_Number
    WHERE ATTR.REFRESHED_TS > @LastRefresh_Date
    and ATTR.[NAME] not in (select [NAME] from [sp_staging].[ATTRIBUTE_REMOVED])
    )
    MERGE INTO sp.Attribute as x
      USING AttributeCTE AS s
      ON  (
            s.Attribute_Number = x.Attribute_Number
          )
          WHEN MATCHED AND EXISTS
          (
              SELECT 
                s.Attribute_Name, 
                s.Attribute_Format, 
                s.Attribute_Unit, 
                s.FormatInteger_scale,
                s.FormatString_scale,
                s.FormatFloat_sign,
                s.FormatFloat_precision,
                s.FormatFloat_scale,
                s.List_Of_Values_ID
              EXCEPT
              SELECT  
                x.Attribute_Name, 
                x.Attribute_Format, 
                x.Attribute_Unit, 
                x.FormatInteger_scale,
                x.FormatString_scale,
                x.FormatFloat_sign,
                x.FormatFloat_precision,
                x.FormatFloat_scale,
                x.List_Of_Values_ID
          )
          THEN
              UPDATE SET 
                Attribute_Format = s.Attribute_Format,
                Attribute_Unit = s.Attribute_Unit,
                FormatInteger_scale = s.FormatInteger_scale,
                FormatString_scale = s.FormatString_scale,
                FormatFloat_sign = s.FormatFloat_sign,
                FormatFloat_precision = s.FormatFloat_precision,
                FormatFloat_scale = s.FormatFloat_scale,
                List_Of_Values_ID = s.List_Of_Values_ID, 
                LastModified_Date = s.LastModified_Date
          WHEN NOT MATCHED BY TARGET
          THEN
              INSERT(
                Attribute_Number, 
                Attribute_Name, 
                Attribute_Format, 
                Attribute_Unit, 
                FormatInteger_scale,
                FormatString_scale,
                FormatFloat_sign,
                FormatFloat_precision,
                FormatFloat_scale,
                List_Of_Values_ID,
                LastModified_Date)
              VALUES(
                s.Attribute_Number, 
                s.Attribute_Name, 
                s.Attribute_Format, 
                s.Attribute_Unit, 
                s.FormatInteger_scale,
                s.FormatString_scale,
                s.FormatFloat_sign,
                s.FormatFloat_precision,
                s.FormatFloat_scale,
                s.List_Of_Values_ID,
                s.LastModified_Date)
          OUTPUT $ACTION, 
        COALESCE(inserted.Attribute_Number, deleted.Attribute_Number) Attribute_Number,
        COALESCE(inserted.Attribute_Name, deleted.Attribute_Name) Attribute_Name
	    INTO @MERGE_RESULTS;

      SELECT @MERGED_ROWS = @@ROWCOUNT;

      SET @LOGMESSAGE = IIF(@DEBUG = 1,(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                ,(SELECT MR.ACTIONTYPE
                                    ,MR.Attribute_Number
                                    ,MR.Attribute_Name
                                  FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                  ,WITHOUT_ARRAY_WRAPPER),'Attribute Modified Rows');

    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        
    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;


  END TRY
  BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
                @ERRORLINE INT= ERROR_LINE();

	      SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
        EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
     
  END CATCH
END
