@call "env.cmd"
%PYTHON_PATH% -m esptool --port %PORT% write_flash -fm dio 0x00000 ../bin/nodemcu-master-7-modules-2019-04-27-13-08-32-float.bin
pause