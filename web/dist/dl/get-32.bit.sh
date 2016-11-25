#!/bin/bash
rsync -irlH --exclude='logs' --exclude='run' --exclude='old' --exclude='web' --del --force --delete-excluded /backup/bkit/clients/HHPT/HP-CLONE/CD0D9B38-0B2A-2747-98C4-48C67799EC5A/data/C.7C9E1BAB._.Fixed-Drive.NTFS/current/bkit/scripts/client/ x32/
U=$(who am i | awk '{print $1}')
chown -R $U:$U x32/

