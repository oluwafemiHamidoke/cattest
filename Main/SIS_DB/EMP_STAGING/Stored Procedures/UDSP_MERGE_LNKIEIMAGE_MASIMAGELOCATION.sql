CREATE PROCEDURE EMP_STAGING.UDSP_MERGE_LNKIEIMAGE_MASIMAGELOCATION
(@MASIMAGELOCIN [dbo].UDTT_LNKIEIMAGE_MASIMAGELOCATION_INSERT_IN READONLY)
AS BEGIN
    SET NOCOUNT ON;

	-- insert into LNKIEIMAGE
	MERGE INTO [EMP_STAGING].[LNKIEIMAGE] target
	USING
	@MASIMAGELOCIN source
	ON
	source.[IESYSTEMCONTROLNUMBER] = target.[IESYSTEMCONTROLNUMBER] AND
	source.[GRAPHICCONTROLNUMBER] = target.[GRAPHICCONTROLNUMBER] AND
	source.[GRAPHICSEQUENCENUMBER] = target.[GRAPHICSEQUENCENUMBER]
	when not matched then
	insert values (source.[IESYSTEMCONTROLNUMBER], source.[GRAPHICCONTROLNUMBER], source.[GRAPHICSEQUENCENUMBER], source.[LASTMODIFIEDDATE]);

	-- merge into MASIMAGELOCATION
	MERGE INTO [EMP_STAGING].[MASIMAGELOCATION] target
	USING
	@MASIMAGELOCIN source
	ON
	source.[GRAPHICCONTROLNUMBER] = target.[GRAPHICCONTROLNUMBER] AND
	source.[IMAGETYPE] = target.[IMAGETYPE]
	when not matched then
    insert values (source.[GRAPHICCONTROLNUMBER], source.[IMAGETYPE], source.[GRAPHICUPDATEDATE], source.[IMAGELOCATION], source.[LASTMODIFIEDDATE]);


END