move "*.avi" "x:\"
for /F "tokens=*" %%a in ('dir /b *.part01.rar') do (
	@rar x "%%a"&& (for /F "tokens=*" %%b in ("%%~na") do (
		del "%%~nb.part*.rar"
		move "%%~nb.avi" "z:\"
		)
	)