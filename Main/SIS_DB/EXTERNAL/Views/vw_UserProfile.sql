CREATE VIEW [EXTERNAL].[vw_UserProfile]
	AS SELECT a.cws, a.catRecID, b.Profile_ID, b.Last_Modified_On Last_Modified_On
from admin.[User] a inner join admin.User_AccessProfile_Relation b on a.User_ID=b.User_ID
