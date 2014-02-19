move "*.avi" "z:\_tv-series\Modern Marvels\"
move "*.mpg" "z:\_tv-series\Modern Marvels\"
move "*.mpeg" "z:\_tv-series\Modern Marvels\"
for /F "tokens=*" %%a in ('dir /b *.part*1.rar ^| findstr /i /r "\.part0*1\.rar"') do (
	@rar x "%%a"&& (
		for /F "tokens=*" %%b in ("%%~na") do (
			del "%%~nb.part*.rar"
			move "*.avi" "z:\_tv-series\Modern Marvels\"
			move "*.mpg" "z:\_tv-series\Modern Marvels\"
			move "*.mpeg" "z:\_tv-series\Modern Marvels\"
			)
		)
	)