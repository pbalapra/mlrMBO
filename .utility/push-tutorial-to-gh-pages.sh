#!/bin/bash

# following
# https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
# and less: https://benlimmer.com/2013/12/26/automatically-publish-javadoc-to-gh-pages-with-travis-ci/

if [ "$TRAVIS_REPO_SLUG" == "mlr-org/mlrMBO" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "gh-pages" ]; then

  echo -e "Publishing tutorial...\n"

  cd ~/$TRAVIS_REPO_SLUG
  git config --global user.email $GIT_EMAIL
  git config --global user.name $GIT_NAME
  git checkout gh-pages
  git config push.default matching
  git add devel
  git commit -m "update auto-generated tutorial pages [ci skip]"

  # Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
  ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
  ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
  ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
  ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
  openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
  chmod 600 deploy_key
  eval `ssh-agent -s`
  ssh-add deploy_key

  git push

  echo -e "Published tutorial to gh-pages.\n"
  
fi
