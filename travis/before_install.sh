#!/bin/bash

# Don't source setup.sh here, because the virtualenv might not be set up yet

set -ex

export NUMCORES=`grep -c ^processor /proc/cpuinfo`
if [ ! -n "$NUMCORES" ]; then
  export NUMCORES=`sysctl -n hw.ncpu`
fi
echo Using $NUMCORES cores

# Install dependencies
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
  # Install protobuf
  pb_dir="~/.cache/pb"
  mkdir -p "$pb_dir"
  wget -qO- "https://github.com/google/protobuf/releases/download/v${PB_VERSION}/protobuf-${PB_VERSION}.tar.gz" | tar -xz -C "$pb_dir" --strip-components 1
  ccache -z
  cd "$pb_dir" && ./configure && make -j${NUMCORES} && make check && sudo make install && sudo ldconfig
  ccache -s

  # Setup Python.
  if [ "${PYTHON_VERSION}" == "python3" ]; then
    export PYTHON_DIR="$(ls -d /opt/python/3.*.*)/bin"
  elif [ "${PYTHON_VERSION}" == "python2" ]; then
    export PYTHON_DIR="$(ls -d /opt/python/2.*.*)/bin"
  else
    echo Unknown Python Version: ${PYTHON_VERSION}
    exit 1
  fi
elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
  brew install ccache protobuf

  # Setup Python.
  export PYTHON_DIR="/usr/local/bin"
  if [ "${PYTHON_VERSION}" == "python3" ]; then
    brew upgrade python
  fi
  brew install ${PYTHON_VERSION}
else
  echo Unknown OS: $TRAVIS_OS_NAME
  exit 1
fi

pip install virtualenv
virtualenv -p "${PYTHON_DIR}/${PYTHON_VERSION}" "${HOME}/virtualenv"
source "${HOME}/virtualenv/bin/activate"
python --version

# Update all existing python packages
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
