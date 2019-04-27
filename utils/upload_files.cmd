@call "env.cmd"
@cd ..\src
@FOR /F "tokens=* USEBACKQ" %%F IN (`dir /b /o:gn`) DO ( %PYTHON_PATH% ..\utils\nodemcu-uploader.py -b %SPEED% --start_baud %SPEED% -p %PORT% upload "%%F")

pause