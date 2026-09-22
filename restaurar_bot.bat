@echo off
title Restaurar Bot y Mejoras de HegalOT
echo ========================================================
echo   Restaurando Bot y Fixes en HegalOT...
echo ========================================================

cd /d "%~dp0"

echo [1/3] Restaurando modulos de bot y terminal...
xcopy /E /I /Y "_bot_backup\modules\game_bot" "modules\game_bot" >nul
xcopy /E /I /Y "_bot_backup\modules\client_terminal" "modules\client_terminal" >nul
xcopy /E /I /Y "_bot_backup\mods\game_healthbars" "mods\game_healthbars" >nul

echo [2/3] Restaurando archivos de audio y sonidos de alarma...
xcopy /E /I /Y "_bot_backup\data\sounds" "data\sounds" >nul
xcopy /E /I /Y "_bot_backup\modules\client\sounds" "modules\client\sounds" >nul
xcopy /E /I /Y "_bot_backup\sounds" "sounds" >nul

echo [3/3] Aplicando fix de teclas walk.lua (sin NumPad)...
copy /Y "_bot_backup\modules\game_walk\walk.lua" "modules\game_walk\walk.lua" >nul

echo.
echo ========================================================
echo   LISTO! Bot restaurado con exito.
echo   Ya puedes abrir el cliente y jugar normalmente.
echo ========================================================
echo.
pause
