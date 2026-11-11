@echo off
pushd "%~dp0"
echo Consultation des devis enregistres dans la base du serveur...
python api\show_quotes.py
echo.
pause
popd
