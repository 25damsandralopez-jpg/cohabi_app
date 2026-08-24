@echo off
setlocal

echo ==========================================
echo COHABI V13 - GESTION AVANZADA DEL PISO
echo ==========================================
echo.

if not exist "pubspec.yaml" (
  echo ERROR: Ejecuta este archivo desde la carpeta raiz del proyecto Cohabi.
  echo Debe existir pubspec.yaml.
  pause
  exit /b 1
)

echo Copiando archivos Dart...
xcopy /E /I /Y "%~dp0lib" "lib" >nul

echo.
echo Copiando migracion SQL al proyecto...
if not exist "supabase\migrations" mkdir "supabase\migrations"
copy /Y "%~dp0supabase\migrations\20260824_v13_property_management.sql" "supabase\migrations\20260824_v13_property_management.sql" >nul

echo.
echo Ejecutando flutter clean...
C:\flutter\bin\flutter.bat clean

echo.
echo Ejecutando flutter pub get...
C:\flutter\bin\flutter.bat pub get

echo.
echo Ejecutando flutter analyze...
C:\flutter\bin\flutter.bat analyze

echo.
echo ==========================================
echo IMPORTANTE
echo Ejecuta tambien el SQL:
echo supabase\migrations\20260824_v13_property_management.sql
echo.
echo Si analyze no muestra ERROR:
echo C:\flutter\bin\flutter.bat run
echo ==========================================
pause
