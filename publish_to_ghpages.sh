#!/bin/sh

set -euo pipefail

cd "$(dirname "$0")"

if [[ $(git status -s) ]]; then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo
echo 'evgeni.io' > public/CNAME

echo "Updating master branch"
cd public
git add --all
git commit -m "Publishing `date`"

echo "Pushing master branch"
git push origin master
