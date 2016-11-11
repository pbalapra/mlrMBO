#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# following
# https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
# and less: https://benlimmer.com/2013/12/26/automatically-publish-javadoc-to-gh-pages-with-travis-ci/

if [ "$TRAVIS_REPO_SLUG" == "mlr-org/mlrMBO" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "gh-pages" ]; then

  echo -e "Publishing tutorial...\n"

  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git checkout gh-pages
  git config push.default matching
  git add devel
  git commit -m "update auto-generated tutorial pages [ci skip]"

  # Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
  openssl aes-256-cbc -K $encrypted_4a432f919f81_key -iv $encrypted_4a432f919f81_iv -in deploy_key.enc -out deploy_key -d
  chmod 600 deploy_key
  eval "$(ssh-agent -s)"
  ssh-add deploy_key

  git push origin gh-pages

  echo -e "Published tutorial to gh-pages.\n"
  
fi
