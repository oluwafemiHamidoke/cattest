﻿Create View sis.vw_RelatedPartsNoKits as
SELECT [PARTNUMBER]
      ,[TYPEINDICATOR]
      ,[RELATEDPARTNUMBER]
      ,[RELATEDPARTNAME]
      ,[NPRINDICATOR]
      ,[LASTMODIFIEDDATE]
  FROM [SISWEB_OWNER].[LNKRELATEDPARTINFO]
  where TYPEINDICATOR not in ('E', 'K')