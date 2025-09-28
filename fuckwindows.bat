@echo off

REM Del WindowsApps 's python*.exe
del /f /q "%LOCALAPPDATA%\Microsoft\WindowsApps\python*.exe"

REM Del DesktopAppInstaller Dir's python*.exe
for /r "%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" %%f in (python*.exe) do (
    echo Del %%f
    del /f /q "%%f"
)

echo Done
pause