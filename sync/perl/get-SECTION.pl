#!/usr/bin/perl -lan
$,=q|.|;
print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|[.]snapshots/@)#);
