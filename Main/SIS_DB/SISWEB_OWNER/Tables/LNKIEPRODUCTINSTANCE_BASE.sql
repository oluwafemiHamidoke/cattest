CREATE TABLE [SISWEB_OWNER].[LNKIEPRODUCTINSTANCE_BASE] (
    [LNKIEPRODUCTINSTANCE_ID]   INT				   NOT NULL,
    [MEDIANUMBER]               VARCHAR (8)        NOT NULL,
    [IESYSTEMCONTROLNUMBER]     VARCHAR (12)       NOT NULL,
    [EMPPRODUCTINSTANCE_ID]     INT                NOT NULL,
    CONSTRAINT [PK_LNKIEPRODUCTINSTANCE] PRIMARY KEY CLUSTERED ([LNKIEPRODUCTINSTANCE_ID] ASC)
);

GO
CREATE NONCLUSTERED INDEX IX_LNKIEPRODUCTINSTANCE_MEDIANUMBER_IESYSTEMCONTROLNUMBER_EMPPRODUCTINSTANCE_ID
    ON SISWEB_OWNER.LNKIEPRODUCTINSTANCE_BASE (MEDIANUMBER ASC, IESYSTEMCONTROLNUMBER ASC, EMPPRODUCTINSTANCE_ID ASC);

GO
CREATE NONCLUSTERED INDEX IX_LNKIEPRODUCTINSTANCE_EMPPRODUCTINSTANCE_ID
ON [SISWEB_OWNER].[LNKIEPRODUCTINSTANCE_BASE] ([EMPPRODUCTINSTANCE_ID])
INCLUDE(MEDIANUMBER, IESYSTEMCONTROLNUMBER)

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'LNKIEPRODUCTINSTANCE_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SHADOW on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER', @level1type = N'TABLE', @level1name = N'LNKIEPRODUCTINSTANCE';

