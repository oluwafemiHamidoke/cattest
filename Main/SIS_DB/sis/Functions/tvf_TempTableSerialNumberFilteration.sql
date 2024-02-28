CREATE FUNCTION sis.tvf_TempTableSerialNumberFilteration(@IESYSTEMCONTROLNUMBER           NVARCHAR(MAX)
                                                        , @SerialNumberPrefix             VARCHAR (10)
                                                        , @StartSerialNumberRange         INT
                                                        , @EndSerialNumberRange           INT)

RETURNS @RETURN_DATASET TABLE
	(
        IESYSTEMCONTROLNUMBER                   VARCHAR(12)     NOT NULL,
        Media_Number                            VARCHAR(8)      NOT NULL,
        ProductStructure_ID                     INT             NOT NULL
    )
AS
BEGIN
        DECLARE @temp_iscn TABLE(
            isc_number VARCHAR(20)
        );

        INSERT into @temp_iscn
        select value isc_number from string_split(@IESYSTEMCONTROLNUMBER,',');

        DECLARE @SerialNumberPrefix_ID int = (select SerialNumberPrefix_ID from sis.SerialNumberPrefix
                                                    where Serial_Number_Prefix=@SerialNumberPrefix)

    INSERT INTO @RETURN_DATASET
        SELECT MS.IESystemControlNumber, M.Media_Number, PIR.ProductStructure_ID
        FROM @temp_iscn temp_iscn
        INNER JOIN sis.MediaSequence MS on temp_iscn.isc_number = MS.IESystemControlNumber
        INNER JOIN sis.MediaSection MSE on MS.MediaSection_ID = MSE.MediaSection_ID
        INNER JOIN sis.ProductStructure_IEPART_Relation PIR on PIR.IEPART_ID = MS.IEPART_ID AND MSE.Media_ID = PIR.Media_ID
        INNER JOIN sis.SerialNumberRange snr ON PIR.SerialNumberRange_ID = snr.SerialNumberRange_ID
        INNER JOIN sis.Media M ON PIR.Media_ID = M.Media_ID
        WHERE PIR.SerialNumberPrefix_ID = @SerialNumberPrefix_ID AND snr.Start_Serial_Number <= @StartSerialNumberRange AND snr.End_Serial_Number >= @EndSerialNumberRange
        GROUP BY MS.IESystemControlNumber, M.Media_Number, PIR.ProductStructure_ID
    RETURN;
END