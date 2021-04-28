#!/bin/bash

GITHUB_TOKEN=$1
EXTENSIONS="ts|tsx|js|jsx"
TARGET_BRANCH=${GITHUB_BASE_REF}

git remote set-url origin https://"${GITHUB_TOKEN}"@github.com/"${GITHUB_REPOSITORY}"

echo "Getting base branch..."
git config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git config --local --add remote.origin.fetch "+refs/tags/*:refs/tags/*"

git fetch --depth=1 origin "${TARGET_BRANCH}":"${TARGET_BRANCH}"

echo "Getting changed files..."

HEAD_SHA=$(git rev-parse "${TARGET_BRANCH}" || true)

FILES=$(git diff --diff-filter=ACMRT --name-only "${HEAD_SHA}" || true)

echo "What are files? ${FILES}"

if [[ -n ${FILES} ]]; then
  CHANGED_FILES=$(echo "${FILES}" | grep -E ".*\.(${EXTENSIONS})$" | grep -v json)

  if [[ -z ${CHANGED_FILES} ]]; then
    echo "Skipping: No files to lint"
    exit 0;
  else
    echo ""
    echo "Running ESLint on..."
    echo "--------------------"
    echo "$CHANGED_FILES"
    echo "--------------------"
    echo ""
    yarn run eslint --config=./eslintrc $CHANGED_FILES
  fi
fi
