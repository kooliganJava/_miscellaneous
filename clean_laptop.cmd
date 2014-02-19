setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=*" %%a in ('dir /b /a:d "C:\Users\kfuller\AppData\Local\NewsBin\SPOOL_V1\alt.*"') do rmdir /s /q "C:\Users\kfuller\AppData\Local\NewsBin\SPOOL_V1\%%a"
del /s /q "C:\Users\kfuller\AppData\Local\Opera\Opera\cache\*"
del /q "C:\Users\kfuller\AppData\Local\Opera\Opera\thumbnails\*"
del /q "C:\Users\kfuller\AppData\Local\QuickPar\*.qp"
del /q "C:\Users\kfuller\AppData\Local\QuickPar\*.bak"
del /s /q "C:\Users\kfuller\AppData\Local\Temp"
for /F "tokens=*" %%a in ('dir /b /a:d "C:\Users\kfuller\AppData\Local\Temp\*"') do rmdir /s /q "C:\Users\kfuller\AppData\Local\Temp\%%a"
for /F "tokens=*" %%a in ('dir /b /a:d "C:\windows\Temp\*"') do rmdir /s /q "C:\windows\Temp\%%a"
for /F "tokens=*" %%a in ('dir /b /a:d "C:\Users\kfuller\AppData\Local\VMware\vmware-custdata*"') do rmdir /s /q "C:\Users\kfuller\AppData\Local\VMware\%%a"
for /F "tokens=*" %%a in ('dir /b /a:d "C:\Users\kfuller\AppData\Local\VMware\vmware-download*"') do rmdir /s /q "C:\Users\kfuller\AppData\Local\VMware\%%a"

C:\Users\kfuller\AppData\Temp


goto :EOF

:killfolders
	set STEM=%*
	for /F "tokens=*" %%a in ('dir /b /a:d "!STEM!*"') do rmdir /s /q "!STEM!%%a"
	exit /b