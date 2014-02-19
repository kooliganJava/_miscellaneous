REM keith fuller
REM	stop_vmware_services
REM	will stop any running services whose name includes the case-insensitive string 'vmware'.
for /F "tokens=*" %%a in ('net start ^| findstr /i vmware') do @net stop "%%a"