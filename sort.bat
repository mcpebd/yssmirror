@echo off
setlocal enabledelayedexpansion

set list=links.json

set "input_major=%1"
set "input_major=%input_major:~0,4%"
for %%f in (*.apk) do (
    set "filename=%%~nxf"
)
for /f "tokens=* skip=1" %%a in ('CertUtil -hashfile "%filename%" SHA256') do set sha256=%%a & goto break
:break

for /f "delims=" %%A in (%list%) do (
    set "memoire=%%A"
    if "!memoire:~-8,4!" equ "%input_major%" (
        echo %%A>>links.json
        echo       {"name":"%filename%","link":"%input_link%","sha256":"%sha256: =%"},>>links.json
    ) else (
        echo %%A>>links.json
    )
)
