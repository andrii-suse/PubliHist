set -euo pipefail

path=$1

test ! -z "$path" || (
    >2 echo "Expected path argument"
    exit 1
)

hist="${PH_HIST}/$path"

test -d "$hist" || (
    >&2 echo "Expected directory, but it is not: {$hist}"
    exit 1
)

ow1="${PH_HIST}/$path#w1"  # out work 1 (rotates with 2 for current and next)
ow2="${PH_HIST}/$path#w2"  # out work 2 (rotates with 1 for current and next)
liv="${PH_LIVE}"/$path

owc="$(readlink -f $liv)"   # out work current
unset own                   # out work next
unset pdt                   # previous dt snapshot folder

if [ "$owc" == "$ow2" ]; then
    owc="$ow2"
    own="$ow1"
elif [ "$owc" == "$ow1" ]; then
    owc="$ow1"
    own="$ow2"
elif ! test -e "$liv" ; then
    echo mkdir -p "$ow1"
    own="$ow1"
else (
    echo "LIVE path {$liv} must link to {$ow1} or {$ow2} instead of {$owc}" >&2
    exit 1
) fi

echo
echo '#' Prepare next live
echo rm -rf "${own}"
echo mkdir "${own}"

olds=($(find "$hist"/../ -mindepth 1 -maxdepth 1 -type d | grep -oP "./$path#\d+$" | grep -oP "#\d+" | sort -r))

cnt=0
max=${PH_LIVE_COUNT:-2}

for r in ${olds[@]}; do
    [[ $cnt -lt $max ]] || break
    ((++cnt))
    echo rsync -a --link-dest="$hist$r" "$hist$r"/ "$own"/
done

echo
echo '#' Point live to next live
echo ln -sfn "$own" "$liv"
echo '#' Clean up old work dir

test "$owc" == "$liv" || echo rm -rf "$owc"
