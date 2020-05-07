#!/usr/bin/env bash

if { true >&3; } 2<> /dev/null 
then
  exec {INFO}>&3
else
  exec {INFO}>&2
fi

while read -p "bkit:>" -a args
do
  [[ -z $args ]] && continue
  declare cmd="${args[0]}"
  case "$cmd" in
    b|bkit)
      bash bkit.sh "${args[@]:1}"
    ;;
    d|dkit)
      bash dkit.sh "${args[@]:1}"
    ;;
    d|rkit)
      bash rkit.sh "${args[@]:1}"
    ;;
    v|vkit)
      bash vkit.sh "${args[@]:1}"
    ;;
    server)
      bash server.sh "${args[@]:1}"
    ;;
    e|exit)
      exit 0
    ;;
    h|help|\?)
      echo -e "bkit\tBackup one or more directories or files"
      echo -e "rkit\tRestore one or more directories or files"
      echo -e "skit\tCreate a shadow copy first and then backup it (Requires Admin privileges on Windows)."
      echo -e "dkit\tShow whether directory differs from the last backup."
      echo -e "vkit\tShow the backups versions of a given file."
      echo -e "help\tTo see this message again."
      echo -e "exit|e\tTo leave from bkit"
      echo -e "\n"
    ;;
    *)
      echo -e "Unrecognize command\nUse help or ? to see a list of possible commands"
    ;;
  esac
done