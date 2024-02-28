CREATE PROCEDURE [sp_staging].[List_Of_Values_Load]
(@DEBUG  BIT = 0 ) -- DEBUG off (0)
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
  
    BEGIN TRY
    
    BEGIN TRANSACTION
    
    DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
            ,@ProcessID UNIQUEIDENTIFIER = NEWID()
            ,@LOV_ROWCOUNT INT = 0
            ,@LOVV_ROWCOUNT INT = 0
            ,@MERGED_ROWS  INT  = 0
            ,@LOGMESSAGE VARCHAR(MAX);

    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;
    
    DECLARE @Format_ValueList VARCHAR(MAX),
            @List_Of_Values_Name VARCHAR(100),
            @List_Of_Values_Number INT,
            @LastModified_Date DATETIME2(7),
            @LastRefresh_Date DATETIME2(7);

    SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM sp.[List_Of_Values];

    -- outer cursor begins -- loop through the data to get the FORMAT_VALUE list split. 
    DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR

    SELECT DISTINCT 
          ID AS List_Of_Values_Number,
          NAME AS List_Of_Values_Name, 
          FORMAT_VALUE AS Format_ValueList,
          A.REFRESHED_TS AS LastModified_Date
    FROM [sp_staging].[ATTRIBUTE] A
    INNER JOIN [sp_staging].[CLASS_ATTRIBUTES] C ON A.ID = C.ATTRIBUTE_ID
    WHERE FORMAT_VALUE IS NOT NULL AND FORMAT_VALUE LIKE '%|%'
    AND A.REFRESHED_TS > (SELECT COALESCE(MAX(LastModified_Date),'1900-01-01') FROM sp.[List_Of_Values])

    OPEN db_cursor

    FETCH NEXT FROM db_cursor INTO @List_Of_Values_Number, @List_Of_Values_Name, @Format_ValueList, @LastModified_Date
    
    WHILE @@FETCH_STATUS = 0  
    BEGIN
      DECLARE @List_Of_Value_ID INT  = NULL
      DECLARE @Current_List_Of_Values_Name VARCHAR(100) = NULL
      DECLARE @MERGE_RESULTS TABLE
      (
        ACTIONTYPE         NVARCHAR(10)
        ,List_Of_Values_ID         VARCHAR(20) NOT NULL
        ,List_Of_Values_Value_Key   VARCHAR(100) NOT NULL
      );
      --gets current name to check if there is a change in name for the current attribute
      SELECT  @List_Of_Value_ID = List_Of_Values_ID,
              @Current_List_Of_Values_Name = List_Of_Values_Name 
      FROM sp.[List_Of_Values] WHERE List_Of_Values_Number = @List_Of_Values_Number;

      IF @List_Of_Value_ID IS NOT NULL AND @Current_List_Of_Values_Name <> @List_Of_Values_Name
      BEGIN
          UPDATE sp.[List_Of_Values] SET
            List_Of_Values_Name = @List_Of_Values_Name, 
            LastModified_Date = @LastModified_Date
          WHERE List_Of_Values_ID = @List_Of_Value_ID;
          
          SET @LOV_ROWCOUNT = @LOV_ROWCOUNT + 1
      END
      ELSE IF @List_Of_Value_ID IS NULL
      BEGIN      
        INSERT INTO sp.[List_Of_Values] VALUES(CAST(@List_Of_Values_Number AS VARCHAR(10)),@List_Of_Values_Name, @LastModified_Date);
        SET @List_Of_Value_ID = SCOPE_IDENTITY();
        SET @LOV_ROWCOUNT = @LOV_ROWCOUNT + 1
      END

      -- List_Of_Values_Value merge based List_Of_Value_ID and split of Format_ValueList
      ;WITH ValueListCTE
      (
        List_Of_Values_ID,
        List_Of_Values_Value_Key,
        List_Of_Values_Value_Name,
        LastModified_Date
      ) AS 
      (
        SELECT DISTINCT
          @List_Of_Value_ID, 
          VALUE, 
          VALUE,
          @LastModified_Date
        FROM STRING_SPLIT(@Format_ValueList, '|')
        WHERE VALUE <> ''
      )

      MERGE INTO sp.List_Of_Values_Value as x
      USING ValueListCTE AS s
      ON  (
            s.List_Of_Values_ID = x.List_Of_Values_ID AND
            s.List_Of_Values_Value_Key = x.List_Of_Values_Value_Key
          )
          WHEN MATCHED AND EXISTS
          (
              SELECT s.List_Of_Values_Value_Key, s.List_Of_Values_Value_Name
              EXCEPT
              SELECT x.List_Of_Values_Value_Key, x.List_Of_Values_Value_Name
          )
          THEN
              UPDATE SET List_Of_Values_Value_Name = s.List_Of_Values_Value_Name, LastModified_Date = s.LastModified_Date
          WHEN NOT MATCHED BY TARGET
          THEN
              INSERT(List_Of_Values_ID, List_Of_Values_Value_Key, List_Of_Values_Value_Name, LastModified_Date)
              VALUES(s.List_Of_Values_ID, s.List_Of_Values_Value_Key, s.List_Of_Values_Value_Name, s.LastModified_Date)
          WHEN NOT MATCHED BY SOURCE
		      AND x.List_Of_Values_ID IN(SELECT List_Of_Values_ID FROM ValueListCTE)
          THEN DELETE
		  OUTPUT $ACTION, 
       COALESCE(inserted.List_Of_Values_ID, deleted.List_Of_Values_ID) List_Of_Values_ID,
      COALESCE(inserted.List_Of_Values_Value_Key, deleted.List_Of_Values_Value_Key) List_Of_Values_Value_Key
	    INTO @MERGE_RESULTS;

      SELECT @MERGED_ROWS = @@ROWCOUNT;
      SET @LOVV_ROWCOUNT = @LOVV_ROWCOUNT + @MERGED_ROWS;

      SET @LOGMESSAGE = IIF(@DEBUG = 1,(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                ,(SELECT MR.ACTIONTYPE
                                    ,MR.List_Of_Values_ID
                                    ,MR.List_Of_Values_Value_Key
                                  FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                  ,WITHOUT_ARRAY_WRAPPER),'List_Of_Values_Value Modified Rows');
      
      IF @DEBUG = 1 -- only in debug mod, write large repeated logs
      BEGIN
          EXEC sp_staging.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
      END

      DELETE FROM @MERGE_RESULTS -- reset the records

    FETCH NEXT FROM db_cursor INTO @List_Of_Values_Number, @List_Of_Values_Name, @Format_ValueList, @LastModified_Date
    END 

    CLOSE db_cursor  
    DEALLOCATE db_cursor

    COMMIT TRANSACTION

    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'List_Of_Values Load' , @DATAVALUE = @LOV_ROWCOUNT;
    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'List_Of_Values_Value Load' , @DATAVALUE = @LOVV_ROWCOUNT;
    
    EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;

    RETURN 0
  END TRY
  BEGIN CATCH
        IF @@TRANCOUNT > 0
			      ROLLBACK TRANSACTION
        -- if cursor status is open =1, the close and deallocate
        IF CURSOR_STATUS('global','db_cursor') = 1
        BEGIN
            CLOSE db_cursor  
            DEALLOCATE db_cursor
        END
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
                @ERRORLINE INT= ERROR_LINE();

	      SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
        EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
     
  END CATCH
END