#!t/lib/test-in-image.sh
set -e
work=$(mktemp -d)

in=$work/in
hist=$work/hist
live=$work/live

mkdir $hist
mkdir $live
mkdir -p $in/folder1

export PH_IN=$in
export PH_HIST=$hist
export PH_LIVE=$live

touch $in/folder1/pkg1-1.1.rpm

bash bin/ph_hist.sh folder1 | bash
bash bin/ph_live.sh folder1 | bash

ls -la $live/folder1/pkg1-1.1.rpm

sleep 1

echo new version is released
rm $in/folder1/pkg1-1.1.rpm
echo 1 > $in/folder1/pkg1-1.2.rpm

bash bin/ph_hist.sh folder1 | bash
ls -la $hist/folder1#2*/pkg1-1.1.rpm
ls -la $hist/folder1#2*/pkg1-1.2.rpm

bash bin/ph_live.sh folder1 | bash

ls -la $live/folder1/pkg1-1.1.rpm
ls -la $live/folder1/pkg1-1.2.rpm

sleep 1

echo version 3 is released
rm $in/folder1/pkg1-1.2.rpm
echo 1 > $in/folder1/pkg1-1.3.rpm

PH_RETAIN_COUNT=1 bash bin/ph_retain.sh folder1 | bash -xe
ls -la $hist/folder1#2*/pkg1-1.2.rpm
rs=0
ls -la $live/folder1#2*/pkg1-1.1.rpm 2>/dev/null || rs=$?
echo Chek old version was removed
test $rs -gt 0

echo publish again and then check only versions 2 and 3 are there
bash bin/ph_hist.sh folder1 | bash
bash bin/ph_live.sh folder1 | bash

rs=0
ls -la $live/folder1/pkg1-1.1.rpm 2>/dev/null || rs=$?
test $rs -gt 0
ls -la $live/folder1/pkg1-1.2.rpm
ls -la $live/folder1/pkg1-1.3.rpm

echo success
