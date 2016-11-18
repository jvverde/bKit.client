#!/bin/bash
gulp build
cd dist
cp -afv index-*.html ./index.html
cd ..
cp -varf app/images/logo/ dist/images/
#rsync -avv --delete ./dist/ ../electron/recovery/
rsync -avv ./dist/ ../electron/recovery/
