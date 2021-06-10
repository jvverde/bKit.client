#!/usr/bin/env bash
set -uE
sdir="$(dirname "$(readlink -f "$0")")"       #Full DIR

die(){ echo -e "$@" >&2 && exit 1;}
usage() {
  local name=$(basename -s .sh "$0")
  echo Backup a given Virtual Machine
  echo -e "Usage:\n\t $name VirtualMachineName"
  exit 1
}

[[ ${1+x} == x ]] || usage

declare -r vm="$1"
declare -r location="${2:-${sdir}/$vm}"
declare -a disks=() sources=() targets=()

declare -r snaps="${location}/snapshots"

mkdir -pv "$snaps"

virsh -c qemu:///system dumpxml "$vm" > "$location/${vm}.xml"

declare -i line=0
while read  -r type device target source
do
  (( ++line == 1 )) && {
    [[ $type == Type && $device == Device && $target == Target && $source == Source ]] || die "First line not match '$type == Type && $device == Device && $target == Target && $source == Source'"
    continue
  }
  (( line == 2 )) && continue
  [[ $type == file && $device == disk ]] || continue
  targets+=( "$target" )
  declare file="$snaps/${vm}-${target}.$(date +%Y-%m-%d.%Hh%Mm%Ss.%N).qcow2"
  sources+=( "$source" )
  disks+=( "--diskspec $target,file=$file")
  #echo $line $type $device $target $source
done < <(virsh -c qemu:///system domblklist "$vm" --details)
echo virsh snapshot-create-as --domain $vm ${disks[@]+"${disks[@]}"} --disk-only --atomic | bash -
#BACKUP
for src in ${sources[@]+"${sources[@]}"}
do
  bkit.sh --all "$src"
done
for target in ${targets[@]+"${targets[@]}"}
do
  virsh blockcommit $vm "$target" --active --pivot --shallow --verbose
done
exit 0

