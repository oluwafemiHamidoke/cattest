
CREATE View [sis].[vw_AsShippedPart2] WITH SCHEMABINDING as 

SELECT L2.[SERIALNUMBER]
      ,L2.[PARTSEQUENCENUMBER]
      ,L2.[PARTNUMBER]
      ,L2.[PARTNAME]
      ,L2.[PARENTPARTNUMBER]
      ,L2.[ATTACHMENTSERIALNUMBER]
      ,L2.[SOURCELOCATION]
      ,L2.[EMDPROCESSEDDATE]
      ,L2.[PARTTYPE]
      ,cast(L2.[ID] as bigint) [ID]
      ,L2.[ParentID]
      ,L2.[LASTMODIFIEDDATE]
      ,L2.[isValidSerialNumber]
      ,L2.[isValidPartNumber]
      ,L2.[SNP]
      ,L2.[SNR]
      ,L2.[ParentPartNumberShort]
	  ,2 LevelNumber
	  ,R.PARENTPARTNUMBER L0_PartNumber
	  ,R.PARTNUMBER L1_PartNumber
	  ,L2.PARTNUMBER L2_PartNumber
	  ,cast(NULL as varchar(20)) L3_PartNumber
  FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] L2
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] R on L2.ParentID = R.ID_Int
GO

CREATE UNIQUE CLUSTERED INDEX [IDX_vw_AsShippedPart2]
    ON [sis].[vw_AsShippedPart2]([ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_vw_AsShippedPart2_SerialNumber]
    ON [sis].[vw_AsShippedPart2]([SERIALNUMBER] ASC);

