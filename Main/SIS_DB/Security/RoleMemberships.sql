
ALTER ROLE [db_owner] ADD MEMBER [sisautomation];
GO

ALTER ROLE [db_owner] ADD MEMBER [sisattunity];
GO

ALTER ROLE [db_ddladmin] ADD MEMBER [sisattunity];
GO

ALTER ROLE [db_datareader] ADD MEMBER [sisattunity];
GO

--ALTER ROLE [db_datareader] ADD MEMBER [sugank];
--GO

--ALTER ROLE [db_datareader] ADD MEMBER [gorosm];
--GO

ALTER ROLE [db_datawriter] ADD MEMBER [sisattunity];
GO

--ALTER ROLE [db_datawriter] ADD MEMBER [siscontainerservice];
--GO

