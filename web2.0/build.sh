#!/bin/bash
gulp build
cd dist
ln -vs index-793acdbac8.html ./index.html
cd ..
cp -varf app/images/logo/ dist/images/
