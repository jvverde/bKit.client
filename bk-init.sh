#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
section=bkit
port=8733
user=us3r
workdir=.bkit
pass=us3r
aclstimeout=3600*24*8
[[ $1 == "-m" ]] && MANIF=1 && shift
SERVER=$1
[[ "$SERVER" == "" ]] && echo -e "Usage:\n\t$0 [-m] server-address" && exit 1
NC=$(find $DIR -type f -path "*/cygwin/*" -name "nc.exe" -print | head -n 1)
echo Contacting the server ... please wait!
[[ -e "$NC" ]] && ( $NC -z $SERVER $port 2>/dev/null && echo "Server OK" || (echo "Server $SERVER not respond on port $port" && exit 1)) || exit 1
echo continue...
#exit

uuid="$(wmic csproduct get uuid /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~ /uuid/ {print $2}' | sed '#\r+##g') "
domain="$(wmic computersystem get domain /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /domain/ {print $2}' | sed '#\r+##g')"
name="$(wmic computersystem get name /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /name/ {print $2}' | sed '#\r+##g')"

MANIFDIR="$DIR/run"
MANIFILE="$MANIFDIR/manifest.txt"
date +%X
[ $MANIF ] && find /cygdrive/? -maxdepth 0 -type d -printf "%f\0" |xargs -0 -I{} find /cygdrive/{} -not -empty -type f -printf "{}|/%P\n" > $MANIFILE
date +%X
RSYNC=$(find $DIR -type f -name "rsync.exe" -print | head -n 1)
#echo $RSYNC

${RSYNC} -rltvvhR --inplace --stats ${MANIFDIR}/./ rsync://admin\@${SERVER}:${port}/${section}/win/${domain}/${name}/${uuid}

[[ "$?" -ne "0" ]] && echo "Exit value of rsync is non null: $?" && exit 1

CONFDIR=$DIR/conf
find $CONFDIR -type f -name "init.sample" -print |xargs cat|
sed -e "s#_USER_#user#g" -e "s#_SERVER_#${SERVER}#g" -e "s#_PORT_#${port}#g"|
sed -e "s#_DOMAIN_#${domain}#g" -e "s#_NAME_#${name}#g" -e "s#_UUID_#${uuid}#g"|
sed -e "s#_WORKDIR_#${workdir}#g" -e "s#_PASS_#${pass}#g"  > $CONFDIR/init.conf  
#my $cfg = new Config::Simple(syntax=>'http');
#$cfg->param('url',"rsync://${user}\@${server}:${port}/${domain}.${name}.${uuid}");
#$cfg->param('pass',$pass);
#$cfg->param('workdir',$workdir);
#$cfg->param('aclstimeout',$aclstimeout);


#$cfg->save("$confDir\\init.conf") or die "Error while saving init.conf file to $confDir";

#print "Saved configuration to $confDir\\init.conf";

#print qx|$perl $cd\\set-assoc.pl $cd\\admin-rkit.pl -o $cd\\logs\\rkit.log|;
#$? and die "Exit value of set-assoc.pl is non null: $?";

#print "Associated bkit extension with rkit";

