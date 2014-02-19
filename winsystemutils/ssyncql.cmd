SET LOCALFOLDER=%USERPROFILE%\Application Data\Microsoft\Internet Explorer\Quick Launch
SET LOCALCOPY=%USERPROFILE%\Application Data\Microsoft\Internet Explorer\Quick Launch LPTP
SET REMOTEFOLDER=z:\Documents and settings\kfuller\Application Data\Microsoft\Internet Explorer\Quick Launch
SET REMOTECOPY=z:\Documents and settings\kfuller\Application Data\Microsoft\Internet Explorer\Quick Launch Ashbel
SET COMMONFOLDER=%USERPROFILE%\Application Data\Microsoft\Internet Explorer\Quick Launch Common

FOR %%L IN ("%COMMONFOLDER%\*") DO IF NOT EXIST "%LOCALCOPY%\%%~nL%%~xL" DEL "%%L"
FOR %%L IN ("%COMMONFOLDER%\*") DO IF NOT EXIST "%REMOTECOPY%\%%~nL%%~xL" DEL "%%L"
