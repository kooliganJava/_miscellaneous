REM Will join split files
REM files must have the .001 .002 .00n extension.

for /F "tokens=*" %a in ('dir /b /o:n *.001') do for /F "tokens=*" %b in ('dir /b /o:n "%~na*"') do if exist "%~na" (copy /y "%~na" + "%b" "%~na.tmp"&& move "%~na.tmp" "%~na") else (copy /y "%b" "%~na")