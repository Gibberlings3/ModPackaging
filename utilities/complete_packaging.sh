#!/bin/bash

echo $0


# /* make sure everything is in order */
if [ -z "${mod_folder}" ]
then
  echo This batch file should not be run directly.
  echo Please make a copy of package_real_mod.sh, edit the copy to match your mod, and run that file.
  exit 127
fi

echo "Packaging ${mod_name}, ${mod_version}:"

# /* set up remaining variables */
export mod_setup="setup-${mod_folder}"
export archive_name="${mod_folder}-${mod_version}"
export win_archive="${archive_name}.zip"
export osx_archive_tar="osx-${archive_name}.tar"
export osx_archive="${osx_archive_tar}.gz"
export lin_archive_tar="lin-${archive_name}.tar"
export lin_archive="${lin_archive_tar}.gz"
export files="${mod_folder}"

# /* automatically detect .tp2 located outside of mod folder */
if [ -f "${mod_folder}.tp2" ]
then
  set files="${files} ${mod_folder}.tp2"
fi
if [ -f "setup-${mod_folder}.tp2" ]
then
  set files="${files} setup-${mod_folder}.tp2"
fi

export win_files="${files} ${mod_setup}.exe"
export osx_files="${files} ${mod_setup} ${mod_setup}.command"
export lin_files="${files}"

export sfx_ico="${ico_folder}/g3icon.ico"
export sfx_banner="${ico_folder}/g3banner.bmp"
export sfx_conf="mod.conf"

# /* remove any previously created archives */
rm -f "$win_archive" >/dev/null 2>&1
rm -f "$osx_archive" >/dev/null 2>&1
rm -f "$lin_archive" >/dev/null 2>&1

# /* copy over latest WeiDU versions */
cp -f "$(dirname $0)/../weidu/weidu" "${mod_setup}" >/dev/null
cp -f "$(dirname $0)/../weidu/weidu.exe" "${mod_setup}.exe" >/dev/null

# /* copy over OS X .command script and update it to reference the current mod */
cp -f "$(dirname $0)/../weidu/osx.command" "${mod_setup}.command" >/dev/null
sed -i.bak -e "s/mod_name/${mod_folder}/g" ${mod_setup}.command
rm -f ${mod_setup}.command.bak >/dev/null 2>&1

if [ "${lowercase_filenames}" -eq "1" ]
then
  echo "Lowercasing filenames..."
  
  tolower ${files} ${mod_setup} ${mod_setup}.exe ${mod_setup}.command
  
  echo "Done."
fi

# /* list platform-exclusive files we want to exclude in other archives */
export sox="${audio_folder}/sox"
export oggdec="${audio_folder}/oggdec.exe"
export tisunpack_win32="${tispack_folder}/win32"
export tisunpack_unix="${tispack_folder}/unix"
export tisunpack_osx="${tispack_folder}/osx"
export iconv="${iconv_folder}"
export desktop_ini="${mod_folder}/desktop.ini"
export folder_icon="${ico_folder}/g3.ico"

# /* escape special characters for sed: /, &, \ */

if [ "${build_windows}" -eq "1" ]
then
  echo "Creating ${win_archive} for Windows..."

  rm -f ${sfx_conf}.bak >/dev/null 2>&1
  
  # /* create the windows zip archive */
  zip -r "${win_archive}" ${win_files} -x"${sox}" -x"${tisunpack_unix}" -x"${tisunpack_osx}"

  echo     Done.
fi


if [ "${build_osx}" -eq "1" ]
then
  echo "Creating ${osx_archive} for OS X..."

  # /* create OS X archive */
  tar -c --exclude "${oggdec}" --exclude "${tisunpack_win32}" --exclude "${tisunpack_unix}" --exclude "${iconv}" --exclude "${desktop_ini}" --exclude "${folder_icon}" --exclude "${sfx_banner}" -f "${osx_archive_tar}" -- ${osx_files} >/dev/null
  gzip --best ${osx_archive_tar} >/dev/null
  rm -f ${osx_archive_tar} >/dev/null 2>&1

  echo     Done.
fi


if [ "${build_linux}" -eq "1" ]
then
  echo "Creating ${lin_archive} for Linux..."

  # /* create linux archive */
  tar -c --exclude "${oggdec}" --exclude "${sox}" --exclude "${tisunpack_win32}" --exclude "${tisunpack_osx}" --exclude "${iconv}" --exclude "${desktop_ini}" --exclude "${folder_icon}" --exclude "${sfx_banner}" -f "${lin_archive_tar}" -- ${lin_files} >/dev/null
  gzip --best "${lin_archive_tar}" >/dev/null
  rm -f "${lin_archive_tar}" >/dev/null 2>&1

  echo "Done."
fi


# /* remove generated weidu and .command files */
rm -f "${mod_setup}.exe" >/dev/null 2>&1
rm -f "${mod_setup}" >/dev/null 2>&1
rm -f "${mod_setup}.command" >/dev/null 2>&1

echo "All tasks completed."


