

CREATE View [sis].[vw_AsShippedPart3] WITH SCHEMABINDING as 


SELECT L3.[SERIALNUMBER]
      ,L3.[PARTSEQUENCENUMBER]
      ,L3.[PARTNUMBER]
      ,L3.[PARTNAME]
      ,L3.[PARENTPARTNUMBER]
      ,L3.[ATTACHMENTSERIALNUMBER]
      ,L3.[SOURCELOCATION]
      ,L3.[EMDPROCESSEDDATE]
      ,L3.[PARTTYPE]
      ,cast(L3.[ID] as bigint) [ID]
      ,L3.[ParentID]
      ,L3.[LASTMODIFIEDDATE]
      ,L3.[isValidSerialNumber]
      ,L3.[isValidPartNumber]
      ,L3.[SNP]
      ,L3.[SNR]
      ,L3.[ParentPartNumberShort]
	  ,3 LevelNumber
	  ,R.PARENTPARTNUMBER L0_PartNumber
	  ,R.PARTNUMBER L1_PartNumber
	  ,L2.PARTNUMBER L2_PartNumber
	  ,L3.PARTNUMBER L3_PartNumber
  FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] L3
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] L2 on L3.ParentID = L2.ID_Int
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] R on L2.ParentID = R.ID_Int
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_vw_AsShippedPart3]
    ON [sis].[vw_AsShippedPart3]([ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_vw_AsShippedPart3_SerialNumber]
    ON [sis].[vw_AsShippedPart3]([SERIALNUMBER] ASC);

