@echo off
setlocal

echo Searching for Quartus Prime installation...
echo This might take a minute...

set "QUARTUS_BIN="

:: Check common default paths
for /d %%d in ("C:\intelFPGA_lite\*", "C:\intelFPGA\*", "C:\altera\*") do (
    if exist "%%d\quartus\bin64\quartus_sh.exe" (
        set "QUARTUS_BIN=%%d\quartus\bin64"
        goto :found
    )
    if exist "%%d\quartus\bin\quartus_sh.exe" (
        set "QUARTUS_BIN=%%d\quartus\bin"
        goto :found
    )
)

echo.
echo ERROR: Could not find quartus_sh.exe in the default Intel/Altera directories.
echo If you installed it on another drive (like D:), please open Quartus Prime manually,
echo go to "View -> Tcl Console", and type:
echo    source synthesize_quartus.tcl
echo.
pause
exit /b 1

:found
echo Found Quartus at: %QUARTUS_BIN%
echo Running Synthesis...
"%QUARTUS_BIN%\quartus_sh.exe" -t synthesize_quartus.tcl

echo.
echo Synthesis Complete!
echo Check the newly created "mac_top_64bit.map.rpt" and "mac_top_64bit.sta.rpt" files for your area and timing results.
pause
