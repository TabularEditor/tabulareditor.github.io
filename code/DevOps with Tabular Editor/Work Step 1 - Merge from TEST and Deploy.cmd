@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET /p branchname="Enter branch name: "

git checkout TEST
git fetch origin
git pull origin TEST

git checkout !branchname!
git merge TEST

START /WAIT TabularEditor.exe AdventureWorks -D localhost AdventureWorks_!branchname! -O -C -P -R -M