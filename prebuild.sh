#!/bin/bash

set -e 
REPO_NAME="cinny"
REPO_URL="https://github.com/cinnyapp/cinny"
REPO_BRANCH="dev"
APP_TARGET="dist"

REPO_VERSION="2.1.2"
CLICK_VERSION_PREFIX=""

NODE_VERSION="v16.15.0"


walk () {
  echo "Entering $1"
  cd $1
}

cleanup () {
  if [ -d "${ROOT}/${REPO_NAME}" ]; then
    echo "Cleaning up"
    rm -rf "${ROOT}/${REPO_NAME}" "${ROOT}/target"
  fi
}

clone () {
  echo "Cloning source repo"
  git clone "${REPO_URL}" "${ROOT}/${REPO_NAME}" --depth=1 --branch="v${REPO_VERSION}"
}

apply_patches () {
  echo "Patching cinny source code"
  if [ -d "${ROOT}/patches" ]; then
    for patch in ${ROOT}/patches/*.patch; do
      echo "Applying $patch"
      git apply ${patch}
    done
  fi
  cp "${ROOT}/svg/cinny_512.svg" "${ROOT}/assets/logo.svg"
  cp "${ROOT}/svg/cinny_18.svg" "${ROOT}/cinny/public/res/svg/cinny.svg"
}


setup_node () {
  echo "Setting up node $NODE_VERSION"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  nvm install $NODE_VERSION
}

build () {
  echo "Building cinny"
  npm install
  npm run build
}

package () {
  echo "Packaging cinny"
  cp -r "${APP_TARGET}" "${ROOT}/target"
  sed -i "s/@CLICK_VERSION@/$REPO_VERSION$CLICK_VERSION_PREFIX/g" "${ROOT}/manifest.json.in"
}

cleanup
clone
walk "${ROOT}/${REPO_NAME}"
apply_patches
setup_node
build
package
