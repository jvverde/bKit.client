#!/usr/bin/env bash
#REVER ESTE CODIGO. ESTA MUITO CONFUSO
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

declare -a options=()
while [[ $1 =~ ^- ]]
do
  KEY="$1" && shift
  case "$KEY" in
    --dry-run)
      options=('--dry-run')
    ;;
    *)
      echo Unknow option $KEY && usage
    ;;
  esac
done

target="${1:-.}"
exists cygpath && target=$(cygpath -u "$target")
target=$(readlink -nm "$target")

dir=$(dirname -- "$target")
[[ -d $dir ]] || mkdir -pv "$dir"
rel=${target#$sdir}
[[ $rel == $sdir ]] && die "Update dir must be $sdir or a subdir"
OIFS=$IFS
IFS=/ steps=( $rel )
IFS=$OIFS

set -f
unset B
filters=()
for S in "${steps[@]}"
do
  [[ -z $S ]] && continue
  C="$B/$S"
  filters+=( --filter="+ $C" )
  filters+=( --filter="- $B/*" )
  B="$C"
done


export RSYNC_PASSWORD="4dm1n"
dst="${2:-.}"
[[ -e $dst ]] || mkdir -p "$dst"
src="$UPDATERSRC"
rsync -rlcRb "${filters[@]}" "${options[@]}" --backup-dir="${dst%/}/.backups/$(date +"%Y-%m-%dT%H-%M-%S")" --out-format="%p|%t|%o|%i|%b|%l|%f" "$src" "${dst%/}/" || die "Problemas ao actualizar $dst"
[[ $? -eq 0 ]] && echo "Actualizaçao feita com com sucesso"
