-- =============================================
-- Author:      Obieda Ananbeh
-- Create Date: 05182023
-- Description: load sistele data(sistele stands for telematics)
-- =============================================

CREATE TABLE [sis_stage].[ssf_sistele](
    SN_PREFIX varchar(3) NOT NULL,
    SN_START_RANGE int NOT NULL,
    SN_END_RANGE int NOT NULL,
    APP_ID int NULL,
    COMP_ID int NULL,
    LOC_CD int NULL,
    SUFFIX varchar(255) NULL,
    SW_PN varchar(255) NULL,
    PRODUCT_LINK_CONFIG varchar(255) NULL
)
