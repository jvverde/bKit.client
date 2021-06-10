#!/usr/bin/env bash
set -uE
sdir="$(dirname "$(readlink -f "$0")")"       #Full DIR

die(){ echo -e "$@" >&2 && exit 1;}
usage() {
  local name=$(basename -s .sh "$0")
  echo Backup all Virtual Machine
  echo -e "Usage:\n\t $name"
  exit 1
}


declare -i line=0
while read  -r id name state
do
  (( ++line == 1 )) && {
    [[ $id == Id && $name == Name && $state == State ]] || die "First line not match '$id == Id && $name == Name && $state == State'"
    continue
  }
  (( line == 2 )) && continue
  [[ -z $name ]] && continue 
  "$sdir/backup-vm.sh" $name
done < <(virsh -c qemu:///system list)

exit 0

