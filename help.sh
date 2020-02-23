#!/usr/bin/env bash
OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
if [[ $OS == cygwin ]]
then 
  ext='.bat' 
else 
  ext='.sh'
  dot='./'
fi

echo -e "\n\nWellcome to bKit console. These are the available commands"
echo -e "Just call a command with option --help to see the available options"
echo -e "\t${dot}bkit${ext}\tBackup one or more directories or files"
echo -e "\t${dot}rkit${ext}\tRestore one or more directories or files"
echo -e "\t${dot}skit${ext}\tCreate a shadow copy first and then backup it (Requires Admin privileges on Windows)."
echo -e "\t${dot}dkit${ext}\tShow whether directory differs from the last backup."
echo -e "\t${dot}vkit${ext}\tShow the backups versions of a given file."
echo -e "\t${dot}help${ext}\tTo see this message again."
echo -e "\n\n"
