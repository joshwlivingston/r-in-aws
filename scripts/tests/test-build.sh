#!/bin/bash

# /scripts/tests/test-build.sh
# 
# Loads R package in built Docker image, verifying successfull container build

docker run --rm --entrypoint Rscript lift-model-local:test -e "library(r.package); cat('OK\n')"
