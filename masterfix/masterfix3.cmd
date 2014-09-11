@echo off
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

:join_parts
	REM For any *.000 *.001 *.002 etc files, join them
	for /F "tokens=*" %%a in ('dir /b *.000') do @if exist "%%~na*par2" (@par2 repair "%%~na*par2"&&if exist "%%~na.bat" "%%~na.bat")
	for /F "tokens=*" %%a in ('dir /b *.000') do @if exist "%%~na" @del "%%~na.*"

for /F "tokens=*" %%a in ('dir /b *.rar') do call :process_file "%%a"
	REM For 2 part movies that we have already renamed
	REM Create a folder for the parts and file them away
	REM inside it.
	for /F "tokens=*" %%a in ('dir /b /a:-d "* a.mpg" "* a.avi" "* a.wmv"') do @(
		set A=%%%%a
		if exist "!A:~1,-5!b%%~xa" @(
			if not exist "!A:~1,-6!" mkdir "!A:~1,-6!"
			move /y "!A:~1,-5!a%%~xa" "!A:~1,-6!\"
			move /y "!A:~1,-5!b%%~xa" "!A:~1,-6!\"
		)
	)
REM exit /b

:process_file
	set PARTFILE=
	set FILENAME=
	set FILE=%1


	REM Test for first parts
	echo !FILE! | findstr /I /R \.part1.rar>nul&&   set PARTFILE=1
	echo !FILE! | findstr /I /R \.part01.rar>nul&&  set PARTFILE=1
	echo !FILE! | findstr /I /R \.part001.rar>nul&& set PARTFILE=1
	REM Test for subsequent parts and exit if so.
	if not defined PARTFILE echo !FILE! | findstr /i /r \.part[0-9][0-9]*\.rar>nul && exit /b

	for /F "tokens=*" %%b in (!FILE!) do if not defined PARTFILE (set FILENAME=%%~nb) else (for /F "tokens=*" %%c in (%%~nb) do (set FILENAME=%%~nc))

	@echo Now processing FILE !FILE! FILENAME !FILENAME!
	call :repair_file
	if !INTEGRITY! == 1 exit /b

	call :unpack_file
	if !INTEGRITY! == 0 (
		call :remove_pars
		call :cleanup
	)
	if !GOODUNPACK! == 0 (
		@echo Unpack successful for !FILE!, removing rars.
		call :remove_rars
	) else (
		@echo Unpack UNsuccessful for !FILE!!
	)
	exit /b

:repair_file
	set INTEGRITY=
	SET STILLBAD=
	if not exist "!FILENAME!*par2" set INTEGRITY=0& exit /b

	:check_old_integrity
		if not exist "!FILENAME!.partmp" goto :check_new_integrity
		for /F "tokens=2" %%d in ('findstr /i /r "target.*r[a0-9][r0-9].*missing" "!FILENAME!.partmp"') do (
			if not exist "%%d" set STILLBAD=1
		)
		if defined STILLBAD @echo !FILENAME! still bad integrity& set INTEGRITY=1& exit /b 1


	:check_new_integrity
		@echo Checking integrity and repairing !FILENAME!
		par2 repair !FILENAME!*par2 | findstr /i /r "^target.*missing" > "!FILENAME!.partmp"
		findstr /i /r "!FILENAME!\.r[a0-9][r0-9].*missing" "!FILENAME!.partmp"|| set INTEGRITY=0
		if !INTEGRITY! == 0 (@echo Integrity for !FILENAME! is good.) else (@echo Integrity for !FILENAME! is BAD.& set INTEGRITY=1)
	exit /b !INTEGRITY!

:unpack_file
	@echo Unpacking !FILENAME!
	set GOODUNPACK=
	rar -o+ -y+ x "!FILE!"
	set GOODUNPACK=!ERRORLEVEL!
	exit /b !ERRORLEVEL!


:remove_rars
	@echo Removing rars for !FILENAME!
	del "!FILENAME!*r??"
	exit /b !ERRORLEVEL!

:remove_pars
	@echo Removing pars for !FILENAME!
	del "!FILENAME!*par2"
	exit /b ERRORLEVEL

:cleanup
	@echo Cleaning up other files for !FILENAME!
	del "!FILENAME!.sfv" "!FILENAME!.nzb" "!FILENAME!.nfo" "!FILENAME!.partmp"
	exit /b