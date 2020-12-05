#!/bin/bash

set -eu

rev=$(git rev-parse HEAD)
release_branch=release

if [[ $(git diff --stat) != '' ]]; then
  echo 'Git tree is dirty, aborting.' >&2
  exit 1
fi

if git submodule status --recursive | grep -e "^[^ ]"; then
  echo "Uninitialized submodules or uncommitted changes. Cannot continue." >&2
  exit 1
fi

# git submodule update --init --recursive

tmp_branch="tmp-$(uuidgen)"

if [[ $(git branch --list $release_branch) == '' ]]; then
    tmp_branch="$release_branch"
fi

echo "Checking out orphaned branch: $tmp_branch"
git checkout --orphan $tmp_branch

submodules=$(git submodule status --recursive)
paths=$(git submodule status | cut -d ' ' -f 3)

for path in $paths; do
    echo git rm --cached "${path}"
    git rm --cached "${path}"
done

find . -name .git -type f | while read git_file; do
  echo "rm $git_file"
  rm $git_file
done

echo "rm .gitmodules"
rm .gitmodules

git add :/
git commit -m "Flatten $rev" -m "$submodules"

if [[ "$tmp_branch" != "$release_branch" ]]; then
    echo "Writing changes to release branch: $release_branch"

    git checkout $release_branch
    git rm -rf -- .
    git checkout $tmp_branch -- .
    git add :/
    git commit -m "Flatten $rev" -m "$submodules"

    git branch -D $tmp_branch
fi
