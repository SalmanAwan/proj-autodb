@echo off
:: **************************************************
:: * Description: Common Single Script Executer
:: **************************************************

set sqlserver=%1
set sqluser=%2
set sqlpw=%3
set sqldb=%4
set script=%5
set filename=%~nx5
set scripttype=%6
set logfile=%7


:: Pre-Script Execution Logging
ECHO ==========%scripttype%========= >> %logfile%	
ECHO %filename% >> %logfile%

:: Formulated Temp Script Execution
CALL sqlcmd -S %sqlserver% -U %sqluser% -P %sqlpw% -d %sqldb% -i %script% >> %logfile%	

:: Post-Script Execution Logging
ECHO %filename%