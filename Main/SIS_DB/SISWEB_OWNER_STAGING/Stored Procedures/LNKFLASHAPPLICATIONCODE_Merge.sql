-- =============================================
-- Author:      Sachin Poolamannil
-- Create Date: 20201022
-- Modify Date: 20201027 Add LASTMODIFIEDDATE column to merge
-- Description:  Merge SISWEB_OWNER_STAGING.LNKFLASHAPPLICATIONCODE to SISWEB_OWNER.LNKFLASHAPPLICATIONCODE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKFLASHAPPLICATIONCODE_Merge
    (@FORCE_LOAD BIT = 'FALSE'
    ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
               ,@MERGED_ROWS                   INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);
        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE        NVARCHAR(10)
            ,APPLICATIONCODE   INT          NOT NULL
            ,APPLICATIONDESC   VARCHAR(48)  NOT NULL
            ,LANGUAGEINDICATOR VARCHAR(2)   NOT NULL
            ,ISENGINERELATED   BIT		    NOT NULL
            ,LASTMODIFIEDDATE  DATETIME2(6) NULL);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKFLASHAPPLICATIONCODE', @SISWEB_OWNER_STAGING_TABLE = 'LNKFLASHAPPLICATIONCODE';
        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            /*
                Story Card: #17223, Created by Sooraj Parameswaran
                This section is to insert isEngineRelated column to LNKFLASHAPPLICATIONCODE for a static list shared. 
                The below section can be removed later once LNKFLASHAPPLICATIONCODE.IsEngineRelated column is started populating from NUP
            */
            
            CREATE TABLE #Flashfile_Descriptions (
                APPLICATIONCODE     INT,
                APPLICATIONDESC     VARCHAR(48),
                ISENGINERELATED     BIT
            )

            insert into #Flashfile_Descriptions
            values
                (1,'ENGINE',1),
                (2,'IMPLEMENT',0),
                (3,'MACHINE',0),
                (4,'MONITOR',0),
                (5,'POWERTRAIN',0),
                (6,'VIDS',0),
                (7,'VIMS',0),
                (8,'GENERATOR SET',0),
                (9,'MONITOR-VIMS/VIDS',0),
                (10,'MACHINE-SECURITY SYSTEM',0),
                (11,'MSS',0),
                (12,'MACHINE-PRODUCT LINK',0),
                (13,'GENERATOR SET-GENERATOR CONTROLL',0),
                (14,'GENERATOR SET-CDVR_1',0),
                (15,'ENGINE-BACKUP',1),
                (16,'MONITOR-ADVISOR',0),
                (17,'ENGINE-PRIMARY',1),
                (18,'MACHINE-CHASSIS',0),
                (19,'MACHINE-IBC',0),
                (20,'MONITOR-EMSIII',0),
                (21,'MONITOR-RAC',0),
                (22,'POWERTRAIN-REAR',0),
                (23,'POWERTRAIN-AWD',0),
                (24,'POWERTRAIN-MG',0),
                (25,'POWERTRAIN II',0),
                (26,'IMPLEMENT-GRADE CONTROL',0),
                (27,'POWERTRAIN-CHASSIS',0),
                (28,'POWERTRAIN-ECPC',0),
                (29,'MACHINE-TCS',0),
                (30,'MONITOR-MESSENGER',0),
                (31,'MONITOR-PCS TPMS',0),
                (32,'MACHINE-ARC',0),
                (33,'ECM_TYPE_ENGINE',1),
                (34,'ECM_TYPE_MACHINE_INFORMATION_DIS',0),
                (35,'ECM_TYPE_TRANSMISSION',0),
                (36,'MACHINE-TPI',0),
                (37,'IMPLEMENT-SLAVE',0),
                (38,'MONITOR-TPI',0),
                (39,'ECM_TYPE_PRODUCT_LINK',0),
                (40,'POWERTRAIN-MACHINE',0),
                (41,'ECM_TYPE_MONITORING_SYSTEM',0),
                (42,'ECM_TYPE_IMPLEMENT_CONTROL',0),
                (43,'IMPLEMENT-SLAVE2',0),
                (44,'MACHINE-OPERATOR INPUT MODULE',0),
                (45,'TRANSMISSION',0),
                (46,'PRODUCT_LINK',0),
                (47,'ENGINE-REAR SLAVE',1),
                (48,'ENGINE-FRONT SLAVE',1),
                (49,'MACHINE-EWPC',0),
                (50,'POWERTRAIN-POWER MODULE',0),
                (51,'POWERTRAIN-PROPULSION MODULE',0),
                (52,'MACHINE-APC',0),
                (53,'ENGINE-ISM-1',1),
                (54,'IMPLEMENT-STEERING',0),
                (55,'MONITOR-VIMS MAIN',0),
                (56,'GENERATOR SET-RTD_1',0),
                (57,'ENGINE-ISM-2',1),
                (58,'ENGINE-ASM',1),
                (59,'ENGINE-SECONDARY',1),
                (60,'MONITOR-VIMS APPLICATION',0),
                (61,'ECM_TYPE_IMPLEMENT_CONTROL_2',0),
                (62,'ENGINE-CONFIG ONLY',1),
                (63,'PAYLOAD_CONTROL_SYSTEM',0),
                (64,'MONITORING_SYSTEM',0),
                (65,'ANALYSIS_CONTROL',0),
                (66,'IMPLEMENT_CONTROL_2',0),
                (67,'ECM SLAVE 1',0),
                (68,'ECM SLAVE 2',0),
                (69,'ICSM 1',0),
                (70,'ICSM 2',0),
                (71,'MACHINE_INFORMATION_DISPLAY_SYST',0),
                (72,'ECM_TYPE_MACHINE_CONTROL',0),
                (73,'CUSTOMER_COMMUNICATION_MODULE',0),
                (74,'IMPLEMENT-AUXILIARY',0),
                (75,'ENGINE_2_OR_REAR',1),
                (76,'GENERATOR SET-THERMOCOUPLE_1',0),
                (77,'MACHINE-GRADE CONTROL',0),
                (78,'MARINE_POWER_DISPLAY',0),
                (79,'MONITOR-MESSAGE DISPLAY APPLICAT',0),
                (80,'GENSET_CONTROL_1',0),
                (81,'MACHINE_CONTROL',0),
                (82,'MACHINE-LEFT STATION',0),
                (83,'MACHINE-RIGHT STATION',0),
                (84,'MACHINE-SLAVE',0),
                (85,'POWERTRAIN-GENERATOR CONTROL MOD',0),
                (86,'TRUCK_PAYLOAD_SYSTEM',0),
                (87,'POWERTRAIN-GENERATOR CONTROL MOD',0),
                (88,'IMPLEMENT-HVAC',0),
                (89,'ENGINE-REAR',1),
                (90,'PROPULSION MODULE 2',0),
                (91,'INTEGRATED_TEMPERATURE_SENSOR_MO',0),
                (92,'MONITOR-CIODS VISION ONLY',0),
                (93,'MONITOR-CIODS RADAR',0),
                (94,'ALL_WHEEL_DRIVE',0),
                (95,'BRAKE',0),
                (96,'ENGINE_8',1),
                (97,'IMPLEMENT_CONTROL',0),
                (98,'TRANSMISSION_CHASSIS',0),
                (99,'VIMS_VIDS_MAIN',0),
                (100,'ENGINE_3',1),
                (101,'IMPLEMENT_CONTROL_3',0),
                (102,'MACHINE-TPS',0),
                (103,'VOLTAGE_REGULATOR',0),
                (104,'TRANSMISSION_2_OR_REAR',0),
                (105,'GATEWAY_NETWORK_EXPLORER',0),
                (106,'MONITOR-PL GSM APPLICATION',0),
                (107,'MACHINE-PRODUCT LINK RADIO',0),
                (108,'ENGINE-AFTERTREATMENT',1),
                (109,'AFTERTREATMENT',1),
                (110,'EDC',0),
                (111,'EMC',0),
                (112,'ETC',0),
                (113,'RHC',0),
                (114,'GATEWAY_NETWORK_EXPLORER_2',0),
                (115,'ENGINE-ISM',1),
                (116,'ENGINE-REAR-AFTERTREATMENT',1),
                (117,'PRODUCT LEVEL',0),
                (118,'ECM_TYPE_GATEWAY_NETWORK_EXPLORE',0),
                (119,'NONE',0),
                (120,'UNKNOWN',0),
                (121,'IMPLEMENT-CONTROL',0),
                (122,'MONITOR-IC DISPLAY',0),
                (123,'MONITOR-PREMIUM VALUE DISPLAY',0),
                (124,'SECONDARY DISPLAY',0),
                (125,'MONITOR-GRADE CONTROL DISPLAY',0),
                (126,'MONITOR-INDICATION DISPLAY',0),
                (127,'MONITOR-INFORMATION DISPLAY',0),
                (128,'ANNUNCIATOR_OR_ALARM_MODULE',0),
                (129,'DISCRETE_INPUT_OUTPUT',0),
                (130,'SHIFT_LEVER',0),
                (131,'MONITOR-TELEMATICS DEVICE',0),
                (132,'ELECTRONIC_MODULAR_CONTROL_PANEL',0),
                (133,'INFORMATION_DISPLAY',0),
                (134,'DEF_CONTROL_1',1),
                (135,'ENGINE_1',1),
                (136,'OBJECT_DETECTION_SYSTEM',0),
                (137,'MACHINE-SEAT CONTROL',0),
                (138,'MACHINE-SUSPENSION CONTROL',0),
                (139,'TEMPERATURE_SENSING_MODULE_4',0),
                (140,'THERMOCOUPLE',0),
                (141,'CHASSIS_CONTROL',0),
                (142,'MACHINE_INFORMATION_DISPLAY_SYST',0),
                (143,'INSTRUMENT_CLUSTER',0),
                (144,'MONITOR-300E DISPLAY',0),
                (145,'MONITOR-MESSAGE DISPLAY CONFIGUR',0),
                (146,'DEF_CONTROL_2',1),
                (147,'UNDEFINED',0),
                (148,'ENGINE',1),
                (149,'ENGINE-CONFIG ONLY',1),
                (150,'Engine-Front Slave',1),
                (151,'Engine-Rear Slave',1),
                (152,'Engine Primary',1),
                (153,'Engine Backup',1),
                (154,'Engine-Secondary',1),
                (155,'Engine-ISM-1',1),
                (156,'Engine-ASM',1),
                (157,'ECM Slave 1',0),
                (158,'ECM Slave 2',0),
                (159,'ICSM 1',0),
                (160,'ICSM 2',0),
                (161,'ENGINE-ISM-2',1),
                (162,'ENGINE-REAR',1),
                (163,'ENGINE-AFTERTREATMENT',1),
                (164,'ENGINE-DEF CONTROLLER',1),
                (165,'ENGINE-REAR-AFTERTREATMENT',1),
                (166,'ENGINE-REAR-DEF CONTROLLER',1),
                (167,'IMPLEMENT',0),
                (168,'AUXILIARY',0),
                (169,'AUTODIG',0),
                (170,'IMPLEMENT/CRUISE CONTROL',0),
                (171,'REAR HITCH',0),
                (172,'CROSS MODULATION',0),
                (173,'IMPL/SLAVE',0),
                (174,'IMPL/SLAVE 2',0),
                (175,'IMPL/Steering',0),
                (176,'Submodule Valve',0),
                (177,'Submodule Valve_2',0),
                (178,'Submodule Valve_3',0),
                (179,'Submodule Valve_4',0),
                (180,'Submodule Valve_5',0),
                (181,'RESERVED',0),
                (182,'RESERVED',0),
                (183,'RESERVED',0),
                (184,'RESERVED',0),
                (185,'RESERVED',0),
                (186,'RESERVED',0),
                (187,'RESERVED',0),
                (188,'RESERVED',0),
                (189,'RESERVED',0),
                (190,'RESERVED',0),
                (191,'RESERVED',0),
                (192,'RESERVED',0),
                (193,'GRADE CONTROL',0),
                (194,'Air Conditioning Compressor Comm',0),
                (195,'Indication Driver Module (IDM)',0),
                (196,'Implement - Primary Slave',0),
                (197,'Implement - Secondary Slave',0),
                (198,'Steering Control',0),
                (199,'A/C Compressor - Gateway',0),
                (200,'MACHINE',0),
                (201,'CHASSIS',0),
                (202,'IBC',0),
                (203,'ARC',0),
                (204,'TCS',0),
                (205,'GENSET',0),
                (206,'SECURITY SYSTEM',0),
                (207,'TPI',0),
                (208,'OPERATOR INPUT MODULE',0),
                (209,'TPS',0),
                (210,'Product Link',0),
                (211,'MACHINE/SLAVE',0),
                (212,'MACHINE/SLAVE 2',0),
                (213,'MACHINE/SLAVE 3',0),
                (214,'MACHINE/SLAVE 4',0),
                (215,'MACHINE/SLAVE 5',0),
                (216,'GRADE CONTROL',0),
                (217,'EWPC',0),
                (218,'APC',0),
                (219,'Time Tag Control',0),
                (220,'Product Link Radio',0),
                (221,'Remote Operator Station',0),
                (222,'LEFT STATION',0),
                (223,'RIGHT STATION',0),
                (224,'Brake Control',0),
                (225,'Traction Control',0),
                (226,'SUSPENSION CONTROL',0),
                (227,'SEAT CONTROL',0),
                (228,'MONITOR',0),
                (229,'MIDS',0),
                (230,'EMSIII',0),
                (231,'VIMS/VIDS',0),
                (232,'RAC',0),
                (233,'TPI',0),
                (234,'M300',0),
                (235,'PCS/TPMS',0),
                (236,'ADVISOR',0),
                (237,'TCS',0),
                (238,'Messenger',0),
                (239,'VIMS A4:N4 Main',0),
                (240,'VIMS Application',0),
                (241,'SMART Signal',0),
                (242,'Message Display Application',0),
                (243,'CMPD',0),
                (244,'Indication Display',0),
                (245,'IC Monitor',0),
                (246,'IC Display',0),
                (247,'PL-GSM Main Board Application',0),
                (248,'PL-GSM Application File',0),
                (249,'CIODS-Vision Only',0),
                (250,'CIODS-Radar Upgrade',0),
                (251,'Premium Value Display',0),
                (252,'Grade Control Display',0),
                (253,'Aftertreatment Display Applicati',1),
                (254,'300E Display',0),
                (255,'Information Display Application',0),
                (256,'VIMS A5N2',0),
                (257,'Telematics Device',0),
                (258,'Secondary Display',0),
                (259,'LMT MULTI-PURPOSE DISPLAY(G310)',0),
                (260,'HOUR METER',0),
                (261,'Marine Power Display',0),
                (262,'MineStar Onboard System',0),
                (263,'POWERTRAIN',0),
                (264,'XMSN-AT',0),
                (265,'XMSN-MG',0),
                (266,'XMSN-ECPC',0),
                (267,'XMSN-FRONT',0),
                (268,'XMSN-REAR',0),
                (269,'XMSN/CHASSIS',0),
                (270,'XMSN/BRAKE/STEERING',0),
                (271,'XMSN/MACHINE',0),
                (272,'AWD',0),
                (273,'Propulsion Module',0),
                (274,'Generator Control?Module',0),
                (275,'Power Converter - Interface Modu',0),
                (276,'Dynamic Retard',0),
                (277,'Propulsion Module 2',0),
                (278,'Power Converter - Interface Modu',0),
                (279,'Transmission/Chassis',0),
                (280,'Transmission - ECPC',0),
                (281,'Transmission - Rear',0),
                (282,'Transmission - Steering',0),
                (283,'Powertrain Control Processor',0),
                (284,'GENERATOR SET',0),
                (285,'GENERATOR CONTROLLER_1',0),
                (286,'RESERVED',0),
                (287,'RESERVED',0),
                (288,'RESERVED',0),
                (289,'RESERVED',0),
                (290,'RESERVED',0),
                (291,'RESERVED',0),
                (292,'RESERVED',0),
                (293,'RESERVED',0),
                (294,'RESERVED',0),
                (295,'DISCRETE I/O_1',0),
                (296,'DISCRETE I/O_2',0),
                (297,'DISCRETE I/O_3',0),
                (298,'DISCRETE I/O_4',0),
                (299,'RESERVED',0),
                (300,'RESERVED',0),
                (301,'RESERVED',0),
                (302,'RESERVED',0),
                (303,'RESERVED',0),
                (304,'RESERVED',0),
                (305,'ANALOG I/O_1',0),
                (306,'ANALOG I/O_2',0),
                (307,'ANALOG I/O_3',0),
                (308,'ANALOG I/O_4',0),
                (309,'RESERVED',0),
                (310,'RESERVED',0),
                (311,'RESERVED',0),
                (312,'RESERVED',0),
                (313,'RESERVED',0),
                (314,'RESERVED',0),
                (315,'ANNUNCIATOR_1',0),
                (316,'ANNUNCIATOR_2',0),
                (317,'ANNUNCIATOR_3',0),
                (318,'RESERVED',0),
                (319,'RESERVED',0),
                (320,'RESERVED',0),
                (321,'RESERVED',0),
                (322,'RESERVED',0),
                (323,'RESERVED',0),
                (324,'RESERVED',0),
                (325,'RTD_1',0),
                (326,'RESERVED',0),
                (327,'RESERVED',0),
                (328,'RESERVED',0),
                (329,'RESERVED',0),
                (330,'RESERVED',0),
                (331,'RESERVED',0),
                (332,'RESERVED',0),
                (333,'RESERVED',0),
                (334,'RESERVED',0),
                (335,'THERMOCOUPLE_1',0),
                (336,'THERMOCOUPLE_2',0),
                (337,'RESERVED',0),
                (338,'RESERVED',0),
                (339,'RESERVED',0),
                (340,'RESERVED',0),
                (341,'RESERVED',0),
                (342,'RESERVED',0),
                (343,'RESERVED',0),
                (344,'RESERVED',0),
                (345,'CDVR_1',0),
                (346,'RESERVED',0),
                (347,'RESERVED',0),
                (348,'RESERVED',0),
                (349,'RESERVED',0),
                (350,'RESERVED',0),
                (351,'RESERVED',0),
                (352,'RESERVED',0),
                (353,'RESERVED',0),
                (354,'MONITOR-HOUR METER',0),
                (355,'ENGINE-DIESEL EXHAUST FLUID CONT',1),
                (356,'IMPLEMENT_CONTROL_1',0),
                (357,'BLADE_INCLINATION_SENSING_MODULE',0),
                (358,'COOLANT_TEMPERATURE_CONTROL',0),
                (359,'BLADE_ROTATION_SENSING_MODULE',0),
                (360,'MACHINE_INCLINATION_SENSING_MODU',0),
                (361,'ENGINE-SLAVE 2',1),
                (362,'AFTERTREATMENT_2',1),
                (363,'Actuator Driver  3',0),
                (364,'HEATING_ELEMENT_CONTROL',0),
                (365,'MACHINE-SLAVE2',0),
                (366,'MACHINE_INFORMATION_DISPLAY_SYST',0),
                (367,'Knock Detection Module 1',0),
                (368,'Auxiliary ECM 1',0),
                (369,'Auxiliary ECM 2',0),
                (370,'Integrated Comb Sensing Mod#1',0),
                (371,'Integrated Comb Sensing Mod#2',0),
                (372,'In Cylinder Pressure Module 1',0),
                (373,'In Cylinder Pressure Module 2',0),
                (374,'Knock Detection Module 1',0),
                (375,'Knock Detection Module 2',0),
                (376,'Actuator Driver  1',0),
                (377,'Actuator Driver  2',0),
                (378,'Actuator Driver  3',0),
                (379,'Actuator Driver  4',0),
                (380,'In Cylinder Temperature Module 1',0),
                (381,'In Cylinder Temperature Module 2',0),
                (382,'Air Fuel Ratio Controller 1',0),
                (383,'Air Fuel Ratio Controller 2',0),
                (384,'Transmission',0),
                (385,'Transmission Backup',0),
                (386,'Power Electronic Control',0),
                (387,'HEALTH INTERFACE MODULE',0),
                (388,'OPERATOR CONTROL PANEL',0),
                (389,'MARINE ENGINE CONTROL PANEL',1),
                (390,'TELEMATICS CELLULAR RADIO',0),
                (391,'GRADE_CONTROL',0),
                (392,'POWER_MANAGEMENT',0),
                (393,'MONITOR-M300',0),
                (394,'GRADE_SLOPE',0),
                (395,'MONITOR-VIMS A5N2',0),
                (396,'MONITOR-SECONDARY DISPLAY',0),
                (397,'ENGINE-AFTERTREATMENT',1),
                (398,'ENGINE-FAN CONTROLLER',1),
                (399,'TELEMATICS SATELLITE RADIO',0),
                (400,'PRIMARY DISPLAY',0),
                (401,'DIESEL EXHAUST FLUID GAUGE',0),
                (402,'ALTERNATIVE FUEL GAUGE',0),
                (403,'ROUTER',0),
                (404,'SUPERVISORY CONTROL',0),
                (405,'MONITOR-CMPD',0),
                (406,'SEAT_CONTROL',0),
                (407,'MONITOR OPERATOR CONTROL PANEL',0),
                (408,'MONITOR-TELEMATICS RADIO MODULE',0),
                (409,'INPUT_OUTPUT_MODULE',0),
                (410,'MONITOR-TELEMATICS SATELLITE RAD',0),
                (411,'OPERATOR_CONTROL_PANEL',0),
                (412,'SECURITY_SYSTEM_KEYPAD',0),
                (413,'AUXILARY_HYDRAULIC',0),
                (414,'MONITOR-PRIMARY DISPLAY',0),
                (415,'ENGINE-ACTUATOR DRIVER 4',1),
                (416,'MACHINE_INFORMATION_DISPLAY_SYST',0),
                (417,'ENGINE-FAN CONTROLLER',1),
                (418,'FAN_CONTROL',0),
                (419,'VCM',0),
                (420,'MONITOR-PL GSM MASTER BOARD',0),
                (421,'MACHINE-BRAKE CONTROL',0),
                (422,'SUPSENSION_SYSTEM_CONTROL',0),
                (423,'TRANSMISSION_2',0),
                (424,'THERMOCOUPLE_1',0),
                (425,'TRANSMISSION BACKUP',0),
                (426,'ANALYSIS_MODULE',0),
                (427,'ENGINE-DIESEL EXHAUST FLUID CONT',1),
                (428,'MONITOR-IC MONITOR',0),
                (429,'ENGINE-DIESEL EXHAUST FLUID CONT',1),
                (430,'IMPLEMENT-STEERING CONTROL',0),
                (431,'MACHINE-POWER ELECTRONIC CONTROL',0),
                (432,'MONITOR-ANALYSIS MODULE',0),
                (433,'MONITOR-EXHAUST FLUID GAUGE',0),
                (434,'MONITOR-GRADE CONTROL',0),
                (435,'MONITOR-IC MONITOR',0),
                (436,'MONITOR-MIDS',0),
                (437,'MONITOR-TELEMATICS DUAL MODE RAD',0),
                (438,'MONITOR-VISION SYSTEM DISPLAY',0),
                (439,'MONITOR-VISION SYSTEM DISPLAY 2',0),
                (440,'Gaseous Fuel Actuation Control 1',0),
                (441,'Gaseous Fuel Actuation Control 2',0),
                (442,'Steering Control Module #2',0),
                (443,'Hydraulic Pump',0),
                (444,'Power Inverter Control',0),
                (445,'Power Inverter Control 2',0),
                (446,'Power Inverter Control 3',0),
                (447,'Power Inverter Control 4',0),
                (448,'Heating/Air Conditioning',0),
                (449,'Marine Master Controller',0),
                (450,'Machine 2',0),
                (451,'Underground Obj Detect Control',0),
                (452,'Underground Obj Detect Sensing',0),
                (453,'Interface Module #1',0),
                (454,'Interface Module #2',0),
                (455,'Bluetooth Transceiver',0),
                (456,'Collision Avoidance Interface',0),
                (457,'Autonomy ECM',0),
                (458,'Braking - Steering',0),
                (459,'Analysis Module',0),
                (460,'Meter-Fuel Flow',0),
                (461,'Navigational Satellite Receiver',0),
                (462,'ANGLE SENSOR',0),
                (463,'Display Interface Module',0),
                (464,'Vision System Display',0),
                (465,'Object Detection System Display',0),
                (466,'Product Link Generation',0),
                (467,'Work Tool/Asset Tracking Device',0),
                (468,'Vision System Display #2',0),
                (469,'Proximity Data Logger',0),
                (470,'Minestar Proximity Awareness',0),
                (471,'Grade Control',0),
                (472,'TELEMATICS AFTERMARKET DEVICE',0),
                (473,'Underground Obj Detect  Display',0),
                (474,'Telematics Dual Mode Radio',0),
                (475,'Operation and Maintenance Manual',0),
                (476,'Primary/Secondary Display',0),
                (477,'Collision Awareness/Avoidance',0),
                (478,'System Control Module',0),
                (479,'Minestar Fleet On-Board',0),
                (480,'Truck Spotting Display',0),
                (481,'Ticketing Interface Module',0),
                (482,'Inverter Power Management',0),
                (483,'AC Load Control',0),
                (484,'Energy Storage Control',0),
                (485,'Energy Storage Monitor #1',0),
                (486,'Energy Storage Monitor #2',0),
                (487,'Battery Charger Control #1',0),
                (488,'Battery Charger Control #2',0),
                (489,'Proximity Detection Interface Mo',0),
                (490,'Energy Storage Monitor #3',0),
                (491,'Energy Storage Monitor #4',0),
                (492,'Object Detection Control',0),
                (493,'Marine Control Station HMI',0),
                (494,'Telematics Lite Device',0),
                (495,'Ethernet Switch',0),
                (496,'Marine Throttle Leverhead',0),
                (497,'Transducer Module',0),
                (498,'Transducer Module with PLC Inter',0),
                (499,'Power Generation Controller',0),
                (500,'Truck Spotting Module',0),
                (501,'Pump Electronic Monitor System',0),
                (515,'Ethernet Switch',0),
                (516,'Bluetooth Transceiver',0);


            /* END of the temp code */

            /* MERGE command */
            MERGE INTO SISWEB_OWNER.LNKFLASHAPPLICATIONCODE tgt
            USING (
                    select 
                        lnkfpc.APPLICATIONCODE
                        , lnkfpc.APPLICATIONDESC
                        , lnkfpc.LANGUAGEINDICATOR
                        , COALESCE(lnkfpc.ISENGINERELATED, temp.ISENGINERELATED, 0) as ISENGINERELATED
                        , lnkfpc.LASTMODIFIEDDATE
                    FROM SISWEB_OWNER_STAGING.LNKFLASHAPPLICATIONCODE lnkfpc
                    left outer join #Flashfile_Descriptions temp on lnkfpc.APPLICATIONCODE = temp.APPLICATIONCODE
                ) src
            ON
               src.APPLICATIONCODE = tgt.APPLICATIONCODE
               AND src.LANGUAGEINDICATOR = tgt.LANGUAGEINDICATOR
                WHEN MATCHED AND EXISTS(SELECT src.APPLICATIONDESC, src.LASTMODIFIEDDATE, src.ISENGINERELATED
                                        EXCEPT
                                        SELECT tgt.APPLICATIONDESC, src.LASTMODIFIEDDATE, tgt.ISENGINERELATED)
                  THEN UPDATE SET 
                    tgt.APPLICATIONDESC = src.APPLICATIONDESC
                    , tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
                    , tgt.ISENGINERELATED = src.ISENGINERELATED
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT(APPLICATIONCODE
                        ,APPLICATIONDESC
                        ,LANGUAGEINDICATOR
                        ,ISENGINERELATED
                        ,LASTMODIFIEDDATE)
                  VALUES
                (src.APPLICATIONCODE
                ,src.APPLICATIONDESC
                ,src.LANGUAGEINDICATOR
                ,src.ISENGINERELATED
                ,src.LASTMODIFIEDDATE)
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.APPLICATIONCODE,deleted.APPLICATIONCODE) APPLICATIONCODE
                  ,COALESCE(inserted.APPLICATIONDESC,deleted.APPLICATIONDESC) APPLICATIONDESC
                  ,COALESCE(inserted.LANGUAGEINDICATOR,deleted.LANGUAGEINDICATOR) LANGUAGEINDICATOR
                  ,COALESCE(inserted.ISENGINERELATED,deleted.ISENGINERELATED) ISENGINERELATED
                  ,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
                   INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.APPLICATIONCODE
                                                                ,MR.APPLICATIONDESC
                                                                ,MR.LANGUAGEINDICATOR
                                                                ,MR.ISENGINERELATED
                                                                ,MR.LASTMODIFIEDDATE
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;

        						UPDATE STATISTICS SISWEB_OWNER.LNKFLASHAPPLICATIONCODE WITH FULLSCAN;

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
               ,@ERRORLINE    INT            = ERROR_LINE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @LOGMESSAGE = 'LINE ' + CAST(@ERRORLINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
    END CATCH;
END;
GO

