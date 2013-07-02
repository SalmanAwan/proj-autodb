@ECHO OFF
REM   First four parameters must be SQL Server Name, Root Login, Root Password and Database Name to create/work with
REM   -createdb : 				Flag to create database if not existing already
REM   -applypatches : 			Flag to execute all scripts in patches folder
REM   -createprocs : 			Flag to execute all stored procedures
REM   -createfunctions : 		Flag to execute all function scripts
REM   -executetests : 			Flag to execute any datasetup and test scripts in test folder


CALL Proj-AutoDB PC005\SQLEXPRESS sa root Test_DB -createdb -applypatches -createprocs -createfunctions -executetests



REM   TIP - Use file names to ensure the order of execution e.g. you can name your patch files something like '20130601_01_DBPatch.sql' to ensure it executes before patch 02