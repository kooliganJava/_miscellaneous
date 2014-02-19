tasklist /fi "imagename eq f5fpclientW.exe" | findstr f5fpclientW.exe&& exit /b
start /d "C:\Program Files\F5 VPN\" f5fpclientW.exe
exit /b