@echo off

REM /* make sure everything is in order */
IF [%mod_folder%]==[] (
  echo This batch file should not be run directly.
  echo Please make a copy of package_real_mod.bat, edit the copy to match your mod, and run that file.
  pause
  exit /b
)

echo Packaging "%mod_name%, %mod_version%":

REM /* set up remaining variables */
set mod_setup=setup-%mod_folder%
set archive_name="%mod_folder%-%mod_version%"
set win_archive=%archive_name%.exe
set osx_archive=mac-%archive_name%.zip
set lin_archive=lin-%archive_name%.zip
set files=%mod_folder%

REM /* automatically detect .tp2 located outside of mod folder */
if exist "%mod_folder%.tp2" set files=%files% %mod_folder%.tp2
if exist "setup-%mod_folder%.tp2" set files=%files% setup-%mod_folder%.tp2

set win_files=%files% %mod_setup%.exe
set osx_files=%files% %mod_setup% %mod_setup%.command
set lin_files=%files%

set sfx_ico=%ico_folder%\g3icon.ico
set sfx_banner=%ico_folder%\g3banner.bmp
set sfx_conf=mod.conf

REM /* generate HTML versions of Markdown files */
dotnet "%~dp0\md2html\md2html.dll" -f https://gibberlings3.github.io/Documentation/readmes/style/g3icon.ico -s https://gibberlings3.github.io/Documentation/readmes/style/g3md.css -o %mod_folder% .

REM /* remove any previously created archives */
del win_archive >nul 2>nul
del osx_archive >nul 2>nul
del lin_archive >nul 2>nul

REM /* copy over latest WeiDU versions */
copy /y "%~dp0..\weidu\weidu" %mod_setup% >nul
copy /y "%~dp0..\weidu\weidu.exe" %mod_setup%.exe >nul

REM /* copy over OS X .command script and update it to reference the current mod */
copy /y "%~dp0..\weidu\osx.command" %mod_setup%.command >nul
"%~dp0\sed.exe" -i.bak "s/mod_name/%mod_folder%/g" %mod_setup%.command
del %mod_setup%.command.bak >nul 2>nul

if [%lowercase_filenames%]==[1] (
  echo   Lowercasing filenames...
  
  call "%~dp0\tolower.exe" %files% %mod_setup% %mod_setup%.exe %mod_setup%.command
  
  echo     Done.
)

REM /* list platform-exclusive files we want to exclude in other archives */
SET sox=%audio_folder%\sox
SET oggdec=%audio_folder%\oggdec.exe
SET tisunpack_win32=%tispack_folder%\win32
SET tisunpack_unix=%tispack_folder%\unix
SET tisunpack_osx=%tispack_folder%\osx
SET tile2ee_win32=%tile2ee_folder%\win32
SET tile2ee_unix=%tile2ee_folder%\unix
SET tile2ee_osx=%tile2ee_folder%\osx
SET iconv=%iconv_folder%
SET desktop_ini=%mod_folder%\desktop.ini
SET folder_icon=%ico_folder%\g3.ico

REM /* escape special characters for sed: /, &, \ */
SET "mod_name=%mod_name:&=\&%"
SET "mod_name=%mod_name:/=\/%"
SET "mod_readme=%mod_readme:&=\&%"
SET "mod_readme=%mod_readme:/=\/%"
SET "compatible_games=%compatible_games:/=\/%"

if [%build_windows%]==[1] (
  echo   Creating %win_archive% for Windows...

  REM /* duplicate the g3 template sfx configuration file and swap the actual mod information into the copy */
  copy /y "%~dp0\g3template.conf" "%sfx_conf%" >nul
  "%~dp0\sed.exe" -i.bak -e "s/#mod_name#/%mod_name%/g" -e "s/#mod_version#/%mod_version%/g" -e "s/#mod_readme#/%mod_readme%/g" -e "s/#mod_setup#/%mod_setup%/g" -e "s/#compatible_games#/%compatible_games%/g" %sfx_conf%
  del %sfx_conf%.bak >nul 2>nul
  
  REM /* create the windows sfx archive, using our modified configuration and setting a custom icon and banner */
  "%~dp0\winrar.exe" a -sfx -z%sfx_conf% -iicon"%sfx_ico%" -iimg"%sfx_banner%" -x%sox% -x%tisunpack_unix% -x%tisunpack_osx% -x%tile2ee_unix% -x%tile2ee_osx% %win_archive% %win_files%

  REM /* remove the generated configuration file */
  del %sfx_conf% >nul 2>nul

  echo     Done.
)

if [%build_windows_zip%]==[1] (
  echo   Creating %archive_name%.zip for Windows...
  
  REM /* create the windows sfx archive, using our modified configuration and setting a custom icon and banner */
  "%~dp0\winrar.exe" a -x%sox% -x%tisunpack_unix% -x%tisunpack_osx% -x%tile2ee_unix% -x%tile2ee_osx% win-%archive_name%.zip %win_files%

  echo     Done.
)

if [%build_osx%]==[1] (
  echo   Creating %osx_archive% for OS X...

  REM /* create OS X archive */
  "%~dp0\7za.exe" a -x^!%oggdec% -x^!%tisunpack_win32% -x^!%tisunpack_unix% -x^!%tile2ee_win32% -x^!%tile2ee_unix% -x^!%iconv% -x^!%desktop_ini% -x^!%folder_icon% -x^!%sfx_banner% %osx_archive% %osx_files% >nul

  echo     Done.
)

if [%build_linux%]==[1] (
  echo   Creating %lin_archive% for Linux...

  REM /* create linux archive */
  "%~dp0\7za.exe" a -x^!%oggdec% -x^!%sox% -x^!%tisunpack_win32% -x^!%tisunpack_osx% -x^!%tile2ee_win32% -x^!%tile2ee_osx% -x^!%iconv% -x^!%desktop_ini% -x^!%folder_icon% -x^!%sfx_banner% %lin_archive% %lin_files% >nul

  echo     Done.
)

REM /* remove generated weidu and .command files */
del %mod_setup%.exe >nul 2>nul
del %mod_setup% >nul 2>nul
del %mod_setup%.command >nul 2>nul

echo   All tasks completed.
pause

endlocal
