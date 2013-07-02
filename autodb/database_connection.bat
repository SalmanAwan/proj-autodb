@ECHO OFF

set sqlinstance=%1
set sqllogin=%2
set sqlpassword=%3

CALL SQLCMD  -S %sqlinstance% -U %sqllogin% -P %sqlpassword% -b -Q "exit(SELECT 0)"