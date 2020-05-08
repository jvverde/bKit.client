#!/usr/bin/env bash
declare -r prog="$0"
declare -r -a arguments="$@"
echo Start "$0" "$@"

if { true >&3; } 2<> /dev/null 
then
  exec {INFO}>&3
else
  exec {INFO}>&2
fi

if [[ $1 =~ -f ]]
then 
  declare -r pipe="${2:-/tmp/test}"

  [[ -p $pipe ]] || mkfifo "$pipe"
fi 

while true 
do
  echo while true
  if [[ ${pipe+isset} == isset ]]
  then
    echo before
    exec {READ}<>"$pipe"
    echo after
  else
    exec {READ}<&0 
  fi
  (
    echo waiting...
    while read -p "bkit:>" -a line
    do
      [[ -z $line ]] && continue
      declare cmd="${line[0]}"
      declare -a args="${line[@]:1}"
      
      case "$cmd" in
        b|bkit)
          args[0]="${args[0]:---help}"
          bash bkit.sh "${args[@]}"
        ;;
        d|dkit)
          args[0]="${args[0]:---help}"
          bash dkit.sh "${args[@]}"
        ;;
        r|rkit)
          args[0]="${args[0]:---help}"
          bash rkit.sh "${args[@]}"
        ;;
        v|vkit)
          args[0]="${args[0]:---help}"
          bash vkit.sh "${args[@]}"
        ;;
        server)
          bash server.sh "${args[@]}"
        ;;
        e|q|exit|quit)
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
    done <&$READ
    exit 1
  ) && exit 0
  exec {READ}<&-
  exec {READ}>&-
  echo "Launch again"
  exec "$prog" "$arguments"
done
