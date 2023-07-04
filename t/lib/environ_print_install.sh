#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then

set -u

# sudo is needed for docker
deps="m4 bash rsync"
test_deps="make which git-core"
test_in_docker_deps="sudo shadow"
test_utils="curl"

echo "zypper refresh"
echo "zypper -n in $deps $test_deps $test_in_docker_deps $test_utils"

else
echo zypper -n in "$@"

fi
