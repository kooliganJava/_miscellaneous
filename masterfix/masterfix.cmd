setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=*" %%a in ('dir /b *.rar') do call :process_file %%~na
exit /b

:process_file
	set FILE=%*

	echo "!FILE!" | findstr /i /r "\.part0*1.*\.rar"
	if ERRORLEVEL 0 (set PARTFILE=1) else (set PARTFILE=)
	if not defined PARTFILE echo "!FILE!" | findstr /i /r "\.part[0-9]+\.rar"&& exit /b
	if exist "!FILE!.par2" call :repair_file
	call :unpack_file
	if ERRORLEVEL 0 (call :remove_rars& call :remove_pars)
	exit /b

:repair_file
	par2 repair !FILE!.par2 | findstr /i /r "^target.*missing" > !FILE!.partmp
	if not ERRORLEVEL 0 findstr /v /i /r "!FILE!\.r[a0-9][r0-9]"
	if ERRORLEVEL (set INTEGRITY=1) else (set INTEGRITY=)
	exit /b

:unpack_file
	rar -o+ -y+ x "!FILE!.rar"
	exit /b ERRORLEVEL


:remove_rars
	if defined PARTFILE goto :remove PARTFILES

	:remove_rarfiles
		echo del "!FILE!.r??"
		exit /b ERRORLEVEL

	:remove_partfiles
		for /F "tokens=*" %%b in ("!FILE!") do @echo del "%%~nb.part*"
		exit /b ERRORLEVEL

:remove_pars
	if defined INTEGRITY echo del "!FILE!*.par2"
	exit /b

:cleanup
	echo del "!FILE!.sfv" "!FILE!.nzb" "!FILE!.nfo"
	exit /b