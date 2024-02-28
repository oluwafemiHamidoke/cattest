-- =============================================
-- Author:      Obieda Ananbeh
-- Create Date: 05182023
-- Description: Retrieve New File from FIDS and Place in New SSF Table
--sistele stands for telematics
-- =============================================

CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Load_SisteleFileData]
AS
BEGIN
  -- Declare a table variable to store IDs of newly inserted rows in the ServiceSoftware_Effectivity table
  DECLARE @InsertedIDs TABLE (ID INT);

  -- Declare a scalar variable to store the ID of the last inserted row in the ServiceSoftware_Effectivity table
  DECLARE @ServiceSoftware_Effectivity_ID INT;

  -- As it is a full load and data remains constant, delete all existing data
  TRUNCATE TABLE [sis_stage].[ServiceSoftware_Effectivity];
  TRUNCATE TABLE [sis_stage].[ServiceSoftware_Effectivity_Suffix];
 
  -- loop through all rows in the ssf_sistele table
  DECLARE curs CURSOR FOR SELECT [SN_PREFIX], [SN_START_RANGE], [SN_END_RANGE], [APP_ID], [COMP_ID], [LOC_CD], [SUFFIX], [SW_PN], [PRODUCT_LINK_CONFIG] FROM [sis_stage].[ssf_sistele];
  OPEN curs;

  DECLARE @SN_PREFIX NVARCHAR(50), @SN_START_RANGE INT, @SN_END_RANGE INT, @APP_ID INT, @COMP_ID INT, @LOC_CD NVARCHAR(50), @SUFFIX NVARCHAR(50), @SW_PN NVARCHAR(50), @PRODUCT_LINK_CONFIG NVARCHAR(50);

  -- Fetch the values from the first row of the ssf_sistele table
  FETCH NEXT FROM curs INTO @SN_PREFIX, @SN_START_RANGE, @SN_END_RANGE, @APP_ID, @COMP_ID, @LOC_CD, @SUFFIX, @SW_PN, @PRODUCT_LINK_CONFIG;

  -- Start the loop through each row in the ssf_sistele table
  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Check if the SerialNumberPrefix exists
    IF EXISTS (SELECT 1 FROM [sis_stage].[SerialNumberPrefix] WHERE Serial_Number_Prefix=@SN_PREFIX)
    BEGIN
      -- Insert data from the fetched row into the ServiceSoftware_Effectivity table 
      -- and store the ID of the inserted row in the table variable @InsertedIDs
      INSERT INTO [sis_stage].[ServiceSoftware_Effectivity]
      (
        [SerialNumberPrefix_ID],
        [Start_Serial_Number],
        [End_Serial_Number],
        [Application_ID],
        [Component_ID],
        [Location_Code],
        [Part_Number],
        [Product_Link_Config],
        [Version]
      )
      OUTPUT INSERTED.ServiceSoftware_Effectivity_ID INTO @InsertedIDs
      VALUES
      (
        (SELECT [SerialNumberPrefix_ID] FROM [sis_stage].[SerialNumberPrefix] WHERE Serial_Number_Prefix=@SN_PREFIX),
        @SN_START_RANGE,
        @SN_END_RANGE,
        @APP_ID,
        @COMP_ID,
        @LOC_CD,
        CASE WHEN CHARINDEX('-', @SW_PN) > 0 THEN LEFT(@SW_PN, CHARINDEX('-', @SW_PN) - 1)ELSE @SW_PN END,
        
      CASE
      WHEN @PRODUCT_LINK_CONFIG LIKE '%-%' THEN
        LEFT(@PRODUCT_LINK_CONFIG, CHARINDEX('-', @PRODUCT_LINK_CONFIG) - 1) +
        SUBSTRING(@PRODUCT_LINK_CONFIG, CHARINDEX('.', @PRODUCT_LINK_CONFIG), LEN(@PRODUCT_LINK_CONFIG))
      ELSE @PRODUCT_LINK_CONFIG
    END,
    CASE WHEN CHARINDEX('-', @SW_PN) > 0 THEN RIGHT(@SW_PN, LEN(@SW_PN) - CHARINDEX('-', @SW_PN))ELSE '00' END 
      );

      -- Get the ID of the newly inserted row from the @InsertedIDs table and assign it to the @ServiceSoftware_Effectivity_ID variable
      SELECT @ServiceSoftware_Effectivity_ID = ID FROM @InsertedIDs;

      -- Insert new suffixes into the ServiceSoftware_Effectivity_Suffix table using the newly inserted ID
      INSERT INTO [sis_stage].[ServiceSoftware_Effectivity_Suffix]
      (
        [ServiceSoftware_Effectivity_ID],
        [Suffix]
      )
      SELECT 
        @ServiceSoftware_Effectivity_ID,
        value 
      FROM STRING_SPLIT(@SUFFIX, ',');
    END

    FETCH NEXT FROM curs INTO @SN_PREFIX, @SN_START_RANGE, @SN_END_RANGE, @APP_ID, @COMP_ID, @LOC_CD, @SUFFIX, @SW_PN, @PRODUCT_LINK_CONFIG;
  END
  CLOSE curs;
  DEALLOCATE curs;
END;