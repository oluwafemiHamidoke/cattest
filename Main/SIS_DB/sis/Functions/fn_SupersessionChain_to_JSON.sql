﻿CREATE FUNCTION sis.fn_SupersessionChain_to_JSON
	(@SUPERSESSIONCHAIN VARCHAR(8000)) 
RETURNS VARCHAR(MAX)
AS
	BEGIN
		RETURN '["' + REPLACE(SUBSTRING(@SUPERSESSIONCHAIN,1,LEN(@SUPERSESSIONCHAIN)),'|','","') + '"]';
	END;