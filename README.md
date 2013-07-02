Project-AutoDB
==============

WHAT & WHY
----------
This project is an effort to automate away part of workflow around Databases in MS SQL Server. The problems this project solves are:

Problem 1: While working on a large application involving complex business scenarios & data sets, it is required to be able to frequently reset database to a known state for ongoing testing & development. This application enabls to automate database setup using existing scripts for Schema, Functions, Procedures & Tests Data.

Problem 2: For Build Automation tool integration e.g. Jenkins. Executes selective Metadata DB Patches and Stored Procedures with a release. "Proj-AutoDB.bat" being parameterized enables the Build Tool to work with different Databases.

Problem 3: Automate New Database Creation along with custom MS SQL Server Users, Logins and User Mappings for it.


HOW TO USE:
-----------
1. Open "Runner.bat" in notepad, and edit MSSQL Server Name, Server Administrator, Password and Database to create/work with
2. Copy your DB Script files (*.sql) in respective folders
3. Save and Double Click Runner.bat. Watch the Scripts executing.
4. View logs in "autodb/logs" folder for any SQL Error Messages while executing scripts. Fix, Delete Database and rerun.


FUTURE ENHANCEMTNS:
-------------------
1. Make DB Script's user and login creation parameterized
2. Provide sample scripts as guide for New Projects

Feel free to fork and extend.