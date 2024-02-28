CREATE TABLE sis_stage.ssf_sisprod_last_run (
    [Serial_Number_Prefix]     varchar(3) NOT NULL,
    [Start_Serial_Number]      int         NULL,
    [End_Serial_Number]        int         NULL,
    [Application_Code]         int         NOT NULL,
    [Part_Number]              varchar(50) NOT NULL
)
GO