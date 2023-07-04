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

basename=${path##*/}

olds=($(find "$hist"/../ -mindepth 1 -maxdepth 1 -type d | grep -oP "./$basename#\d+$" | grep -oP "#\d+" | sort -r))

for r in ${olds[@]}; do
    echo $hist$r
    break
done
:
