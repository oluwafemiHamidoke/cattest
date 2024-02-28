﻿Create View sis.vw_LNKMEDIASNP_Active as
Select 
[MEDIANUMBER],
[SNP],
[BEGINNINGRANGE],
[ENDRANGE],
[INFOTYPEID],
[TYPEINDICATOR],
[LASTMODIFIEDDATE]
From [SISWEB_OWNER].[LNKMEDIASNP]
where [INFOTYPEID] not in (17,18,21,33,34)