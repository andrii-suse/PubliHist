#!t/lib/test-in-image.sh
set -e
work=$(mktemp -d)

in=$work/in
hist=$work/hist

rs=$(environ rs)
$rs/start

live=$rs/dt/live
$rs/configure_dir live $live

mkdir $hist
mkdir $live
mkdir -p $in/folder1

export PH_IN=$in
export PH_HIST=$hist
export PH_LIVE=$live

touch $in/folder1/pkg1-1.1.rpm

bash bin/ph_hist.sh folder1 | bash -xe
bash bin/ph_live.sh folder1 | bash -xe

ls -la $live/folder1/pkg1-1.1.rpm

sleep 1

echo new version is released
rm $in/folder1/pkg1-1.1.rpm
echo 1 > $in/folder1/pkg1-1.2.rpm

bash bin/ph_hist.sh folder1 | bash -xe
ls -la $hist/folder1#2*/pkg1-1.1.rpm
ls -la $hist/folder1#2*/pkg1-1.2.rpm

bash bin/ph_live.sh folder1 | bash -xe

ls -la $live/folder1/pkg1-1.1.rpm
ls -la $live/folder1/pkg1-1.2.rpm

$rs/ls_live /folder1/ | grep pkg1-1.2.rpm

echo success
