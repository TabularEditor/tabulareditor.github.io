@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET /p branchname="Enter new branch name (no spaces): "

git checkout TEST

git checkout -b feature/!branchname!
git push origin feature/!branchname!
git branch -u origin/feature/!branchname!

START /WAIT TabularEditor.exe AdventureWorks -D localhost AdventureWorks_!branchname!

IF /I "!errorlevel!" == "0" (
    ECHO Database AdventureWorks_!branchname! succesfully deployed on 'localhost'.
    SET process=n
    SET /p process="Do you want to perform a full processing of the DB now (Y/[N])? "
    IF /I "!process!"=="y" (
        powershell Invoke-ProcessASDatabase -DatabaseName AdventureWorks_!branchname! -RefreshType Full -Server localhost
        IF /I "!errorlevel!" == "0" ( 
            ECHO Processing succeeded! 
        ) ELSE ( 
            ECHO Processing Failed! 
        ) 
    )
)