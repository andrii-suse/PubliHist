#!/bin/bash
#
# Copyright (C) 2021 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

length=$(($#-1))
packages=${@:1:$length}

[ -z "$packages" ] || echo Additional packages: $packages

testcase="${@: -1}"

[ -n "$testcase" ] || {
  echo "No testcase provided"
  exit 1
}

[ -n "$ENVIRON_TEST_IMAGE" ] || {
  echo "Variable ENVIRON_TEST_IMAGE is not set. It must have value 'local' or a valid docker image"
  exit 1
}

set -eo pipefail

[ -f "$testcase" ] || (echo Cannot find file "$testcase"; exit 1 ) >&2

[ local != "$ENVIRON_TEST_IMAGE" ] || {
    bash -x "$testcase"
    exit $?
}

thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
basename=$(basename "$testcase")
basename=${basename,,}
basename=${basename//:/_}
ident=environ.envtest.${ENVIRON_TEST_IMAGE//\//_}

containername="$ident.${basename,,}"

docker_info="$(docker info >/dev/null 2>&1)" || {
    echo "Docker doesn't seem to be running"
    (exit 1)
}

echo 'FROM '$ENVIRON_TEST_IMAGE'
RUN echo 01 # change this if you want rebuild of container
RUN [ ! -d /etc/zypp ] || sed -i 's,http://,https://,g' /etc/zypp/repos.d/*.repo
ADD environ_print_install* /
RUN bash -x -c "$(/environ_print_install.sh || exit 1)"
RUN [ -z "'$packages'" ] || bash -x -c "$(/environ_print_install.sh '$packages'  || exit 1)"
RUN git clone http://github.com/andrii-suse/environ /opt/environ
WORKDIR /opt/environ
RUN make install
WORKDIR /opt/PubliHist
ENTRYPOINT ["/usr/bin/tail", "-f", "/dev/null"]
' | docker build -t $ident.image -f - $thisdir

docker rm -f "$containername" >&/dev/null || :

docker run --rm --name "$containername" -v"$thisdir/../..":/opt/PubliHist -- $ident.image &

in_cleanup=0

function cleanup {
    [ "$in_cleanup" != 1 ] || return
    in_cleanup=1
    if [ "$ret" != 0 ] && [ -n "$PAUSE_ON_FAILURE" ]; then
        read -rsn1 -p"Test failed, press any key to finish"; echo
    fi
    docker stop -t0 "$containername"
    [ "$ret" == 0 ] || echo FAIL $basename
}

trap cleanup INT TERM EXIT
counter=1

# wait container start
until [ $counter -gt 10 ]; do
  sleep 0.5
  docker exec "$containername" pwd >& /dev/null && break
  ((counter++))
done

docker exec "$containername" pwd >& /dev/null || (echo Cannot start container; exit 1 ) >&2

set +ex

docker exec "$containername" bash -c "useradd $(id -nu) -u $(id -u)"
docker exec "$containername" bash -c "[ ! -f /usr/sbin/nginx ] || chown -R $(id -nu) /var/log/nginx"
docker exec -e TESTCASE="$testcase"  -i "$containername" bash -c "sudo -u \#$(id -u) bash -x" < "$testcase"
ret=$?
( exit $ret )
