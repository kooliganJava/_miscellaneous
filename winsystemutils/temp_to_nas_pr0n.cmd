move "*.avi" "x:\"
move "*.mpg" "x:\"
move "*.mpeg" "x:\"
for /F "tokens=*" %%a in ('dir /b *.part*.rar ^| findstr /i /r "\.part0*1\.rar') do (
	@rar x "%%a"&& (
		for /F "tokens=*" %%b in ("%%~na") do (
			del "%%~nb.part*.rar"
			move "%%~nb.avi" "z:\"
			move "*.mpg" "x:\"
			move "*.mpeg" "x:\"
			)
	)
)