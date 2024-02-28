﻿CREATE TABLE [KIM].[SIS_KitBillOfMaterials] (
    [KITNUMBER]        NVARCHAR (7)  NULL,
    [COMPONENT_NUMBER] NVARCHAR (7)  NULL,
    [QUANTITY]         INT           NULL,
    [PARTNAME]         NVARCHAR (30) NULL,
    [SERVICEABILITY]   NVARCHAR (25) NULL
);




GO
CREATE CLUSTERED INDEX [CI_SIS_KitBillOfMaterials]
    ON [KIM].[SIS_KitBillOfMaterials]([KITNUMBER] ASC);
