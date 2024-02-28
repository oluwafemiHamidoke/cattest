CREATE PROCEDURE [sissearch2].[WriteLog] (
									@LogTYPE     VARCHAR(100) = 'Information'
								   ,@TIME		 datetime = null 
								   ,@NAMEOFSPROC VARCHAR(200)
								   ,@LOGMESSAGE  VARCHAR(MAX) = null
								   ,@DATAVALUE   bigint = NULL
								   ,@ISUPDATE	 bit = 0
								   ,@LAPSETIME	 bigint = NULL
								   ,@LogID		 bigint = NULL) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		if @TIME is null
			set @TIME = getdate()

		if (@ISUPDATE = 0) 
			BEGIN
			INSERT INTO sissearch2.Log(LogDateTime,LogType,LapseTime, NameofSproc,LogMessage,DataValue)
			VALUES (@TIME,@LogTYPE,@LAPSETIME, @NAMEOFSPROC,@LOGMESSAGE,@DATAVALUE);

			RETURN @@IDENTITY;
			END 
		else
			BEGIN
			UPDATE sissearch2.Log
			SET LapseTime= @LAPSETIME,
				LogMessage= @LOGMESSAGE,
				DataValue= @DATAVALUE
				where LogID= @LogID;

				RETURN @@IDENTITY;
			END
		
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERROELINE    INT            = ERROR_LINE();
		INSERT INTO sissearch2.Log(LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (SYSUTCDATETIME(),'Error',@NAMEOFSPROC,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;

