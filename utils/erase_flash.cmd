@call "env.cmd"
%PYTHON_PATH% -m esptool --port %PORT% erase_flash
pause