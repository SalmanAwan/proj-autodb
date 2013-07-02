/************************************************************************
	Creating Database
************************************************************************/

DECLARE
  @TARGET_DB 					VARCHAR(255),
  @CREATE_TEMPLATE 				VARCHAR(255),
  @USE_DATABASE_TEMPLATE		VARCHAR(255),
  @SQL_SCRIPT 					VARCHAR(255)


--SET @TARGET_DB = 'TESTDB3333'
SET @TARGET_DB = '$(targetDB)'
SET @CREATE_TEMPLATE = 'CREATE DATABASE {DBNAME}'
SET @USE_DATABASE_TEMPLATE = 'USE {DBNAME}'

IF EXISTS (
	SELECT DISTINCT(db_name(s_mf.database_id))
	FROM sys.master_files s_mf
	WHERE  db_name(s_mf.database_id) = '$(targetDB)' AND
		s_mf.state = 0 AND
		has_dbaccess(db_name(s_mf.database_id)) = 1)
 BEGIN
   PRINT 'Database ' + @TARGET_DB + ' already exists.'
   RETURN
 END
ELSE
 BEGIN
  SET @SQL_SCRIPT = REPLACE(@CREATE_TEMPLATE, '{DBNAME}', @TARGET_DB)
  EXECUTE (@SQL_SCRIPT)
  PRINT 'Database ' + @TARGET_DB + ' created Successfully'
 END



/************************************************************************
	Creating Login for Server If not Existing & Giving dbcreator Role
************************************************************************/

IF NOT EXISTS (SELECT * FROM sys.server_principals
  WHERE name = 'change_me_db_login')
  BEGIN
       PRINT 'login for change_me_db_login is missing, creating the login'
	   CREATE LOGIN change_me_db_login WITH Password = 'password1234', CHECK_POLICY = OFF
	   EXECUTE sp_addsrvrolemember
			@loginame = 'change_me_db_login',
			@rolename = 'dbcreator'

  END
else
	print 'login for change_me_db_login exists'

	
/************************************************************************
	Creating Users for Selected Database
************************************************************************/

-- Creating New User and Associating it with Login Created Above
IF NOT EXISTS (select * from sys.database_principals dp where name='change_me_db_user')
	BEGIN
		print 'user change_me_db_user is missing, creating the user' 
	END
else
	Begin
		print 'user change_me_db_user exists, dropping and recreating'
		DROP USER change_me_db_user
	End
SET @SQL_SCRIPT = 'USE ' + @TARGET_DB + '; CREATE USER change_me_db_user FOR LOGIN change_me_db_login WITH DEFAULT_SCHEMA = ' + @TARGET_DB;
EXEC (@SQL_SCRIPT)


-- Associating these logins with dbowner roel
SET @SQL_SCRIPT = 'USE ' + @TARGET_DB + '; EXECUTE sp_addrolemember @membername = change_me_db_user, @rolename = db_owner';
EXEC (@SQL_SCRIPT)
