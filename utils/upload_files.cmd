@call "env.cmd"

@echo OFF

cd ..\src

FOR /f "tokens=* USEBACKQ" %%i IN (`git log --pretty^=format:"%%h" -n 1`) DO SET current_commit=%%i
echo %current_commit% > version

echo ^-^-^> Current commit: %current_commit%

echo ON

@FOR /F "tokens=* USEBACKQ" %%F IN (`dir /b /o:gn`) DO ( %PYTHON_PATH% ..\utils\nodemcu-uploader.py -b %SPEED% --start_baud %SPEED% -p %PORT% upload "%%F")

pause