
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200622 
-- Description: Load data into Country ans Country_Translation
-- =============================================
CREATE PROCEDURE sis_stage.Country_Load (@FORCE_LOAD BIT = 'FALSE' -- not used, for future enhancements and consistency with other procs
									   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @MERGED_ROWS INT              = 0
			   ,@PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS_COUNTRY TABLE (ACTIONTYPE   NVARCHAR(10)
											 ,Country_ID   INT NOT NULL
											 ,Country_Code CHAR(2) NOT NULL);

		DECLARE @MERGE_RESULTS_COUNTRY_TRANSLATION TABLE (ACTIONTYPE          NVARCHAR(10)
														 ,Country_ID          INT NOT NULL
														 ,Language_ID         INT NOT NULL
														 ,Country_Description NVARCHAR(150) NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Country Load started',@DATAVALUE = NULL;

		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE Country command */
			WITH Country_VALUES
				 AS (
				 SELECT Country.Country_ID,Country.Country_Code
					 FROM(VALUES 
							(1,'E')
						,	(2,'G')
						,	(3,'-')		--missing translation
						,	(4,'R')		--missing translation
						,	(5,'H')
						,	(6,'A')		--missing translation
						,	(7,'L')		--missing translation
						,	(8,'Q')		--missing translation
						,	(9,'W')		--missing translation
						,	(10,'X')					
						,	(11,'F')	--missing translation
						,	(12,'J')	--missing translation
						,	(13,'.')	--missing translation
						,	(14,'C')
						,	(15,' ')	--missing translation
						,	(16,'M')	--missing translation
						,	(17,'D')	--missing translation
						,	(18,'P')	--missing translation
						,	(19,'V')
						,	(20,'S')
						,	(21,'>')
						,	(22,'I')
						,	(23,'<')	--missing translation
						,	(24,'T')
						,	(25,'B')
						,	(26,'N')	--missing translation
						,	(27,'Z')	--missing translation
						,	(28,'GT')
						,	(29,'RR')
						,	(30,'PS')					 
						,	(31,'MF')
						,	(32,'SE')
						,	(33,'HO')
						,	(34,'LS')
						,	(35,'VA')
						,	(36,'FT')
						,	(37,'LF')
						,	(38,'XJ')
						,	(39,'NQ')
						,	(40,'JS')
						,	(41,'LV')
						,	(42,'MM')
						,	(43,'AL')
						,	(44,'DK')
						,	(45,'AT')
						,	(46,'DX')
						,	(47,'EY')
						,	(48,'GB')
						,	(49,'SV')
						,	(50,'TB')
						,	(51,'CS')	--missing translation
						,	(52,'JH')	--missing translation
						,	(53,'CT')	--missing translation
						,	(54,'WZ')	--missing translation
						,	(55,'XS')
						,	(56,'MX')
						,	(57,'PP')	--missing translation
						,	(58,'PE')
						,	(59,'HR')
					 ) AS Country(Country_ID,Country_Code)
					 )

				 MERGE INTO sis.Country tgt
				 USING Country_VALUES src
				 ON src.Country_ID = tgt.Country_ID
				 WHEN NOT MATCHED BY TARGET
					   THEN
					   INSERT(Country_ID,Country_Code)
					   VALUES (src.Country_ID,src.Country_Code) 
				 WHEN NOT MATCHED BY SOURCE
					   THEN DELETE
				 WHEN MATCHED AND EXISTS
				 (
					 SELECT src.Country_Code
					 EXCEPT
					 SELECT tgt.Country_Code
				 )
					   THEN UPDATE SET tgt.Country_Code = src.Country_Code
				 OUTPUT $ACTION,COALESCE(inserted.Country_ID,deleted.Country_ID) Country_ID,COALESCE(inserted.Country_Code,deleted.Country_Code) Country_Code
						INTO @MERGE_RESULTS_COUNTRY;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS_COUNTRY AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS_COUNTRY AS MR WHERE MR.
				ACTIONTYPE = 'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS_COUNTRY AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.Country_ID,MR.Country_Code
					FROM @MERGE_RESULTS_COUNTRY AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		COMMIT;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Country Load completed',@DATAVALUE = NULL;

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Country Translation Load started',@DATAVALUE = NULL;

		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE Country Translation command */
			WITH Country_Translation_VALUES
				 AS (SELECT Country_Translation.Country_ID,L.Language_ID,Country_Translation.Country_Description
					 FROM(VALUES 
					   (1,'en-US',N'E Glasgow, Scotland'),							(1,'zh-CN',N'苏格兰格拉斯哥')
					 , (2,'en-US',N'G Brazil'),										(2,'zh-CN',N'巴西')
					 , (5,'en-US',N'H France'),										(5,'zh-CN',N'法国')
					 , (10,'en-US',N'X Japan'),										(10,'zh-CN',N'日本')
					 , (14,'zh-CN',N'澳大利亚'),										(14,'en-US',N'C Australia')
					 , (19,'zh-CN',N'比利时'),										(19,'en-US',N'V Belgium')
					 , (20,'en-US',N'S Leicester, England'),						(20,'zh-CN',N'英国莱斯特')
					 , (21,'en-US',N'US United States'),							(21,'zh-CN',N'美国')
					 , (22,'zh-CN',N'日本明石'),										(22,'en-US',N'HE Akashi, Japan')
					 , (24,'zh-CN',N'加拿大'),										(24,'en-US',N'T Canada')
					 , (25,'zh-CN',N'英国纽卡斯尔'),									(25,'en-US',N'B Newcastle, England')
					 , (28,'en-US',N'GT Tosno Russia'),								(28,'zh-CN',N'托斯诺 俄罗斯')
					 , (29,'en-US',N'RR Perkins Japan'),							(29,'zh-CN',N'帕金斯 日本')
					 , (30,'en-US',N'PS Wuxi'),										(30,'zh-CN',N'无锡')
					 , (31,'en-US',N'MF Bangkok Thailand'),							(31,'zh-CN',N'曼谷 泰国')
					 , (32,'en-US',N'SE Seguin United States'),						(32,'zh-CN',N'塞甘 美国')
					 , (33,'en-US',N'HO Elphinstone Australia'),					(33,'zh-CN',N'埃尔芬斯通 澳大利亚')
					 , (34,'en-US',N'LS Newberry United States'),					(34,'zh-CN',N'托斯诺 俄罗斯')
					 , (35,'en-US',N'VA Dortmund Germany'),							(35,'zh-CN',N'多特蒙德 德国')
					 , (36,'en-US',N'FT Shuzhou China'),							(36,'zh-CN',N'蜀州 中国')
					 , (37,'en-US',N'LF Slough England'),							(37,'zh-CN',N'泥沼 英国')
					 , (38,'en-US',N'XJ Asia Power Systems China'),					(38,'zh-CN',N'亚洲 力量 系统 中国')
					 , (39,'en-US',N'NQ Zhengzhou China'),							(39,'zh-CN',N'郑州 中国')
					 , (40,'en-US',N'JS Natra Raya Indonesia'),						(40,'zh-CN',N'开斋节 印度尼西亚')
					 , (41,'en-US',N'LV Cat Work Tools'),							(41,'zh-CN',N'Cat 作业工具')
					 , (42,'en-US',N'MM Xuzhou China'),								(42,'zh-CN',N'徐州 中国')
					 , (43,'en-US',N'AL Albaret France'),							(43,'zh-CN',N'阿尔巴雷特 法国')
					 , (44,'en-US',N'DK Larne North Ireland'),						(44,'zh-CN',N'拉恩 北爱尔兰')
					 , (45,'en-US',N'AT Welbourne Marine Center of Excellence'),	(45,'zh-CN',N'维尔本 海洋 卓越中心')
					 , (46,'en-US',N'DX Petersbourgh England'),						(46,'zh-CN',N'彼得斯堡 英国')
					 , (47,'en-US',N'EY Europe Design Center Germany'),				(47,'zh-CN',N'欧洲 设计 中心 德国')
					 , (48,'en-US',N'GB Peterlee UK'),								(48,'zh-CN',N'彼得利 英国')
					 , (49,'en-US',N'SV CAT Forest Prod Sweden'),					(49,'zh-CN',N'CAT 森林产品 瑞典')
					 , (50,'en-US',N'TB Malasyia'),									(50,'zh-CN',N'马来西亚')
					 , (55,'en-US',N'XS Serbia'),									(55,'zh-CN',N'塞尔维亚')
					 , (56,'en-US',N'MX Mexico'),									(56,'zh-CN',N'墨西哥')
					 , (58,'en-US',N'PE Peru'),										(58,'zh-CN',N'秘鲁')
					 , (59,'en-US',N'HR Croatia'),									(59,'zh-CN',N'克罗地亚')
					 ) AS Country_Translation(Country_ID,Language_Tag,
					 Country_Description)
						 JOIN sis.Language AS L ON L.Language_Tag = Country_Translation.Language_Tag)

				 MERGE INTO sis.Country_Translation tgt
				 USING Country_Translation_VALUES src
				 ON src.Country_ID = tgt.Country_ID AND 
					src.Language_ID = tgt.Language_ID
				 WHEN NOT MATCHED BY TARGET
					   THEN
					   INSERT(Country_ID,Language_ID,Country_Description)
					   VALUES (src.Country_ID,src.Language_ID,src.Country_Description) 
				 WHEN NOT MATCHED BY SOURCE
					   THEN DELETE
				 WHEN MATCHED AND EXISTS
				 (
					 SELECT src.Country_Description
					 EXCEPT
					 SELECT tgt.Country_Description
				 )
					   THEN UPDATE SET tgt.Country_Description = src.Country_Description
				 OUTPUT $ACTION,COALESCE(inserted.Country_ID,deleted.Country_ID) Country_ID,COALESCE(inserted.Language_ID,deleted.Language_ID) Language_ID,COALESCE(inserted.
				 Country_Description,deleted.Country_Description) Country_Description
						INTO @MERGE_RESULTS_COUNTRY_TRANSLATION;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_COUNTRY_TRANSLATION AS MR
					WHERE MR.ACTIONTYPE = 'INSERT'
				) AS Inserted,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_COUNTRY_TRANSLATION AS MR
					WHERE MR.ACTIONTYPE = 'UPDATE'
				) AS Updated,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_COUNTRY_TRANSLATION AS MR
					WHERE MR.ACTIONTYPE = 'DELETE'
				) AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.Country_ID,MR.Language_ID,MR.Country_Description
					FROM @MERGE_RESULTS_COUNTRY_TRANSLATION AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		COMMIT;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Country Translation Load completed',@DATAVALUE = NULL;
		
		
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