#!/usr/bin/env bash
set -uE

while read id name status
do 
  virsh -c qemu:///system domblklist $name --details |tail -n +3 |grep -vP '^block'|sed '/^$/d'
done < <(virsh -c qemu:///system list | tail -n +3 | sed '/^$/d')

