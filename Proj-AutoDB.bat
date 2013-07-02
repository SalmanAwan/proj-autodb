Title "MS SQL Server - Auto DB"

:: 
::	Testing for Windows Version to run this batch file on
:: 
@ECHO OFF
:: Check for Windows NT 4 and later
IF NOT "%OS%"=="Windows_NT" GOTO :IncompatibleWindowsVersion
:: Check for Windows NT 4
VER | FIND "Windows NT" > NUL && GOTO :IncompatibleWindowsVersion
:: Check for Windows 2000
VER | FIND "Windows 2000" > NUL && GOTO :IncompatibleWindowsVersion

setlocal

::
::  System Configurations
::
SET LOGPREPEND=[AUTODB]

:: 
::	Processing Command Line Arguments and Options Selected
:: 
SET sqlinstance= .
SET sqllogin= 	 .
SET sqlpassword= .
SET databasename=.
SET createdb=N
SET applypatches=N
SET createprocs=N
SET createfunctions=N
SET executetests=N


REM Getting Basic Database Connection Information
if .%1 == . (set /P sqlinstance=Enter SQL Server name, or default to 127.0.0.1\SQLEXPRESS: ) else (set sqlinstance=%1)
if .%sqlinstance% == . (set sqlinstance=127.0.0.1\SQLEXPRESS)

if .%2 == . (set /P sqllogin=Enter Login Name, or default to 'sa': ) else (set sqllogin=%2)
if .%sqllogin% == . (set sqllogin=sa)

if .%3 == . (set /P sqlpassword=Enter SQL instance name, or default to 'root': ) else (set sqlpassword=%3)
if .%sqlpassword% == . (set sqlpassword=root)

if .%4 == . (set /P databasename=Enter Database name, or default to 'master': ) else (set databasename=%4)
if .%databasename% == . (set databasename=master)



REM Parsing Command Line Arguments to Detect Which Options Were Chosen
:loop
IF NOT "%1"=="" (
    IF "%1"=="-createdb" (
		SET createdb=Y
	)
	IF "%1"=="-createprocs" (
		SET createprocs=Y
	)
	IF "%1"=="-applypatches" (
		SET applypatches=Y
	)
	IF "%1"=="-createfunctions" (
		SET createfunctions=Y
	)
	IF "%1"=="-executetests" (
		SET executetests=Y
	)

	REM Looping For Next Option
	SHIFT
	GOTO :loop
)


:: Test Batch File Parameters
@ECHO.
@ECHO Connecting To MS SQL Server: %sqlinstance%
@ECHO Login Details: %sqllogin% / %sqlpassword%
@ECHO Database Name: %databasename%
@ECHO.

@ECHO Tasks Selected:
@ECHO Create DB: %createdb%
@ECHO Apply Patches: %applypatches%
@ECHO Create Procs: %createprocs%
@ECHO Create Functions: %createfunctions%
@ECHO Execute Tests: %executetests%


REM Check if no action is selected then give menu
IF "%createdb%" == "N" IF "%applypatches%" == "N" IF "%createprocs%" == "N" IF "%createfunctions%" == "N" IF "%executetests%" == "N"  GOTO :MENU 


REM Some options are selected thus test DB Connection
GOTO :START


:MENU
REM CLS
ECHO.
ECHO ...............................................
ECHO No Action Selected, PRESS 1 or 2 to select your task, or 3 to EXIT. TODO: Need to Present for human interaction
ECHO ...............................................
ECHO.
ECHO 1 - Create New Database
ECHO 2 - No Option Available Yet
ECHO 3 - EXIT
ECHO.



:START
REM TEST_DB_CONNECTION
CALL autodb\database_connection.bat %sqlinstance% %sqllogin% %sqlpassword%

IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not connect to Database Server with provided credentials
	GOTO :ERROR_HANDLER
)ELSE ECHO %LOGPREPEND% Database Connection verified
@ECHO.


REM CREATE_DATABASE
IF "%createdb%"=="Y" ( 
	ECHO %LOGPREPEND% Creating Database
	CALL sqlcmd -S %sqlinstance% -U %sqllogin% -P %sqlpassword% -i autodb\create_database.sql -v targetDB="%databasename%"		 

	REM ERRORLEVEL set by sqlcmd due to -b flag
	IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not create Databas with provided name
		GOTO :ERROR_HANDLER
	)ELSE ECHO %LOGPREPEND% Database Created
	@ECHO.
)


REM APPLY_PATCHES
IF "%applypatches%"=="Y" ( 
	ECHO %LOGPREPEND% Applying Database Patches	
		
	ECHO. > autodb\logs\log_apply_patch.out
	for /r . %%f in (patches\*) DO (		
		CALL autodb\single_script_runner.bat %sqlinstance% %sqllogin% %sqlpassword% %databasename% %%f "DB Patch" autodb\logs\log_apply_patch.out
	)

	REM ERRORLEVEL set by sqlcmd due to -b flag
	IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not apply Patches
		GOTO :ERROR_HANDLER
	)ELSE ECHO %LOGPREPEND% DB Patches Applied	
	@ECHO.
)


REM CREATE_PROCS
IF "%createprocs%"=="Y" ( 
	ECHO %LOGPREPEND% Creating Stored Procedures
	
	ECHO. > autodb\logs\log_create_procedure.out
	for /r . %%f in (procedures\*) DO (		
		CALL  autodb\single_script_runner.bat %sqlinstance% %sqllogin% %sqlpassword% %databasename% %%f "Procedure" "autodb\logs\log_create_procedure.out"
	)
	
	REM ERRORLEVEL set by sqlcmd due to -b flag
	IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not create Stored Procedures
		GOTO :ERROR_HANDLER
	)ELSE ECHO %LOGPREPEND% Stored Procedures Created
	@ECHO.	
)


REM CREATE FUNCTIONS
IF "%createfunctions%"=="Y" ( 
	ECHO %LOGPREPEND% Creating Functions
	
	ECHO. > autodb\logs\log_create_function.out
	for /r . %%f in (functions\*) DO (		
		CALL  autodb\single_script_runner.bat %sqlinstance% %sqllogin% %sqlpassword% %databasename% %%f "Function" "autodb\logs\log_create_function.out"
	)
	
	REM ERRORLEVEL set by sqlcmd due to -b flag
	IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not Execute Tests
		GOTO :ERROR_HANDLER
	)ELSE ECHO %LOGPREPEND% Functions Creation Complete
	@ECHO.
)


REM EXECUTE TEST SCRIPTS
IF "%executetests%"=="Y" ( 
	ECHO %LOGPREPEND% Executing Tests

	ECHO. > autodb\logs\log_execute_test.out	
	
	for /r . %%f in (tests\*) DO (		
		CALL  autodb\single_script_runner.bat %sqlinstance% %sqllogin% %sqlpassword% %databasename% %%f "Test Script" "autodb\logs\log_execute_test.out"
	)
		
	REM ERRORLEVEL set by sqlcmd due to -b flag
	IF "%ERRORLEVEL%" == "1" ( 
	SET ERROR_MESSAGE=Could not Execute Tests
		GOTO :ERROR_HANDLER
	)ELSE ECHO %LOGPREPEND% Tests Execution Complete
	@ECHO.
	
	REM SET pathbuffer=%pathbuffer%
	REM CD tests\
	REM ECHO %pathbuffer%tests\
	REM :treeProcess
	REM for %%f in (*) do echo %pathbuffer%   %%f
	REM for /D %%d in (*) do (
		REM echo %pathbuffer% ^| %%d
		REM cd %%d
		REM SET pathbuffer=%pathbuffer%..
		REM call :treeProcess
		REM CD .. 
		REM SET pathbuffer= %pathbuffer:~0,-2%
	REM )	
	REM exit /b		
	REM CD ..
	
	
	REM 
REM echo %pathbuffer%   %%f
	
	REM for /r . %%f in (tests\*) DO (		
		REM CALL  autodb\single_script_runner.bat %sqlinstance% %sqllogin% %sqlpassword% %databasename% %%f "Test Script" "autodb\logs\log_execute_test.out"
	REM )

)

REM Finished Processing
GOTO :DONE



:IncompatibleWindowsVersion
SET ERROR_MESSAGE="This batch file is not compatible with this Windows Instance"

:ERROR_HANDLER
ECHO %LOGPREPEND% %ERROR_MESSAGE% : Error Level(%ERRORLEVEL%)

:DONE 
Echo %LOGPREPEND% Finished Processing

PAUSE