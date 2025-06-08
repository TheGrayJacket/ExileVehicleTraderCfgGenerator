@echo off
setlocal enabledelayedexpansion

set "inputFile=output.txt"
set "outputFile=exportVehiclesListOutput.hpp"

:: Clear the output file
echo. > "%outputFile%"

:: Count total lines
set /a totalLines=0
for /f "usebackq delims=" %%L in ("%inputFile%") do (
    set /a totalLines+=1
)

:: Initialize counter
set /a counter=0

for /f "usebackq tokens=1-6 delims=;" %%a in ("%inputFile%") do (
    set /a counter+=1
    set "className=%%a"
    set "quality=%%b"
    set "price=%%c"
    set "name=%%e"
    set "type=%%f"

    rem Check if 'type' is a valid identifier
    echo(!type!| findstr /R "^[a-zA-Z_][a-zA-Z0-9_]*$" >nul
    set "isNumber=0"
    if !errorlevel! equ 0 set "isNumber=1"

    if !isNumber! equ 1 (
        >>"%outputFile%" echo class !className!						{ quality = !quality!; price = !price!; }; // !name! /!type!/
    ) else (
        >>"%outputFile%" echo class !className!						{ quality = !quality!; price = !price!; }; // !name!
    )

    :: Print progress message
    echo Processing line !counter! of !totalLines!...
)

echo Done. Output written to %outputFile%
