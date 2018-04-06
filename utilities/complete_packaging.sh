#!/bin/bash


# /* make sure everything is in order */
if [ -z "${mod_folder}" ]
then
  echo "This batch file should not be run directly."
  echo "Please make a copy of package_mod.sh, edit the copy to match your mod, and run that file."
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

export sfx_ico="${ico_folder}/g3icon.ico"
export sfx_banner="${ico_folder}/g3banner.bmp"
export sfx_conf="mod.conf"

# /* remove any previously created archives */
rm -f "$win_archive"
rm -f "$osx_archive"
rm -f "$lin_archive"

# /* copy over latest WeiDU versions */
cp -f "$(dirname $0)/../weidu/weidu" "${mod_setup}"
cp -f "$(dirname $0)/../weidu/weidu.exe" "${mod_setup}.exe"

# /* copy over OS X .command script and update it to reference the current mod */
sed -e "s/mod_name/${mod_folder}/g" "$(dirname $0)/../weidu/osx.command" >"${mod_setup}.command"

if [ "${lowercase_filenames}" -eq "1" ]
then
  echo "Lowercasing filenames..."
  
  tolower "${mod_folder}" "${mod_setup}" "${mod_setup}.exe" "${mod_setup}.command" "${mod_folder}.tp2" "${mod_setup}.tp2"
  
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


if [ "${build_windows}" -eq "1" ]
then
  echo "Creating ${win_archive} for Windows..."

  # /* create the windows zip archive */
  zip -q -r "${win_archive}" "${mod_folder}" "${mod_setup}.exe" -x "${sox}" "${tisunpack_unix}/*" "${tisunpack_osx}/*"
  [ -f "${mod_folder}.tp2" ] && zip -q "${win_archive}" "${mod_folder}.tp2"
  [ -f "${mod_setup}.tp2" ] && zip -q "${win_archive}" "${mod_setup}.tp2"

  echo     Done.
fi


if [ "${build_osx}" -eq "1" ]
then
  echo "Creating ${osx_archive} for OS X..."

  # /* create OS X archive */
  tar -c --exclude "${oggdec}" --exclude "${tisunpack_win32}" --exclude "${tisunpack_unix}" --exclude "${iconv}" --exclude "${desktop_ini}" --exclude "${folder_icon}" --exclude "${sfx_banner}" -f "${osx_archive_tar}" -- "${mod_folder}" "${mod_setup}" "${mod_setup}.command"
  [ -f "${mod_folder}.tp2" ] && tar -r -f "${osx_archive_tar}" -- "${mod_folder}.tp2"
  [ -f "${mod_setup}.tp2" ] && tar -r -f "${osx_archive_tar}" -- "${mod_setup}.tp2"
  gzip --best "${osx_archive_tar}"
  rm -f ${osx_archive_tar}

  echo     Done.
fi


if [ "${build_linux}" -eq "1" ]
then
  echo "Creating ${lin_archive} for Linux..."

  # /* create linux archive */
  tar -c --exclude "${oggdec}" --exclude "${sox}" --exclude "${tisunpack_win32}" --exclude "${tisunpack_osx}" --exclude "${iconv}" --exclude "${desktop_ini}" --exclude "${folder_icon}" --exclude "${sfx_banner}" -f "${lin_archive_tar}" -- "${mod_folder}"
  [ -f "${mod_folder}.tp2" ] && tar -r -f "${lin_archive_tar}" -- "${mod_folder}.tp2"
  [ -f "${mod_setup}.tp2" ] && tar -r -f "${lin_archive_tar}" -- "${mod_setup}.tp2"
  gzip --best "${lin_archive_tar}"
  rm -f "${lin_archive_tar}"

  echo "Done."
fi


# /* remove generated weidu and .command files */
rm -f "${mod_setup}.exe"
rm -f "${mod_setup}"
rm -f "${mod_setup}.command"

echo "All tasks completed."


