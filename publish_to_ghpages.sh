#!/bin/sh

set -euo pipefail

cd "$(dirname "$0")"

if [[ $(git status -s) ]]; then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out master branch into public"
git worktree add -B master public origin/master

git -C public pull

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo
echo 'evgeni.io' > public/CNAME

echo "Updating master branch"
cd public
git add --all
git commit -m "Publishing `date`"

echo "Pushing master branch, run this:"
echo git push origin master
