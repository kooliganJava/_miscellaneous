for /F "skip=4" %%a in ('net share ^| findstr /i /v /c:"the " /c:"IPC$"') do @net share %%a /d