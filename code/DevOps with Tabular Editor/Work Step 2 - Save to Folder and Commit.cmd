@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET /p commitmsg="Commit message: "

START /WAIT TabularEditor.exe localhost AdventureWorks_!branchname! -S fixdbname.cs -F AdventureWorks

git add .
git commit -m "%commitmsg%"
git push origin !branchname!