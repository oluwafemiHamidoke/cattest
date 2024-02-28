


CREATE View [sis].[vw_AsShippedPart1] WITH SCHEMABINDING as 

SELECT [SERIALNUMBER]
      ,[PARTSEQUENCENUMBER]
      ,[PARTNUMBER]
      ,[PARTNAME]
      ,[PARENTPARTNUMBER]
      ,[ATTACHMENTSERIALNUMBER]
      ,[SOURCELOCATION]
      ,[EMDPROCESSEDDATE]
      ,[PARTTYPE]
      ,cast([ID] as bigint) [ID]
      ,[ParentID]
      ,[LASTMODIFIEDDATE]
      ,[isValidSerialNumber]
      ,[isValidPartNumber]
      ,[SNP]
      ,[SNR]
      ,cast(NULL as varchar(50)) [ParentPartNumberShort]
	  ,case when [PARENTPARTNUMBER] is null then 0 else 1 end LevelNumber
	  ,case when [PARENTPARTNUMBER] is null then [PARTNUMBER] else [PARENTPARTNUMBER] end L0_PartNumber --No parent; root.  Has parent then use ParentPartNumber.
	  ,case when [PARENTPARTNUMBER] is null then null else [PARTNUMBER] end L1_PartNumber --has parent; L1
	  ,cast(NULL as varchar(20)) L2_PartNumber
	  ,cast(NULL as varchar(20)) L3_PartNumber
  FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_AsShippedPart1]
    ON [sis].[vw_AsShippedPart1]([ID] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_vw_AsShippedPart1_SerialNumber]
    ON [sis].[vw_AsShippedPart1]([SERIALNUMBER] ASC);

