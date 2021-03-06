#!/bin/bash

source "${0%/*}/setup.sh"

# Mypy only works with Python 3
if [ "${PYTHON_VERSION}" != "python2" ]; then
  time mypy .
  # Also test in python2 mode (but this is still in the python 3 CI
  # instance, because mypy itself needs python 3)
  time mypy --py2 .
fi

#time python setup.py test

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
  time python setup.py test --addopts tests/onnx_backend_models_test.py
  time python setup.py test --addopts tests/onnx_backend_node_test.py
  time python setup.py test --addopts tests/operators_test.py  
  time python setup.py test --addopts tests/transformers_test.py
  time python setup.py test --addopts tests/convert_test.py
fi	

time python setup.py test --addopts tests/graph_test.py

