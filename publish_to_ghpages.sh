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
make clean-html
make clean-markdown

echo "Generating site"
make org-to-markdown
make markdown-to-html
echo 'evgeni.io' > public/CNAME

echo "Updating master branch"
(
    cd public
    git add --all
    git commit -m "Publishing `date`"

    echo "Pushing master branch"
    git push origin master

    echo "Done."
)
