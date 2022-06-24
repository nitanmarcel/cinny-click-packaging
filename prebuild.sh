#!/bin/bash

set -e

export REPO_NAME="cinny"
export REPO_URL="https://github.com/cinnyapp/cinny"
export REPO_BRANCH="dev"
export APP_TARGET="dist"

export REPO_VERSION="2.0.4"
export CLICK_VERSION_PREFIX="notificationfix1"

if [ -d "${ROOT}/${REPO_NAME}" ]; then
    echo "Cleaning up"
    rm -rf "${ROOT}/${REPO_NAME}" "${ROOT}/target"
fi
echo "Cloning source repo"

git clone "${REPO_URL}" -b "${REPO_BRANCH}" "${ROOT}/${REPO_NAME}" --depth=1 --branch="v${REPO_VERSION}"
cd "${ROOT}/${REPO_NAME}"

if [ -d "${ROOT}/patches" ]; then
    echo "Applying patches"
    for patch in ${ROOT}/patches/*.patch; do
        git apply ${patch}
    done
fi

echo "Copying icons"
cp "${ROOT}/svg/cinny_512.svg" "${ROOT}/assets/logo.svg"
cp "${ROOT}/svg/cinny_18.svg" "${ROOT}/cinny/public/res/svg/cinny.svg"

echo "Run npm install"
npm install
echo "Run npm build"
npm run build
echo "Copying ${APP_TARGET}"
cp -r "${APP_TARGET}" "${ROOT}/target"

sed -i "s/@CLICK_VERSION@/$REPO_VERSION$CLICK_VERSION_PREFIX/g" "${ROOT}/manifest.json.in"

cat "${ROOT}/manifest.json.in"

echo "Done. Creating click package."
