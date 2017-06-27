#!/usr/bin/perl -lan
print (m#/data/(?:[^/]+\.){4}[^/]+/(@[^/]+|[.]snapshots/@[^/]+)#)
