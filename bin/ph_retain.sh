set -euo pipefail
path=${1-}
retain=${PH_RETAIN_COUNT:-2}

test ! -z "$path" || (
    >2 echo "Expected path argument"
    exit 1
)

work="${PH_HIST}/$path"

test -d "$work" || (
    >&2 echo "Expected directory, but it is not: {$work}"
    exit 1
)

olds=($(find "$work"/../ -mindepth 1 -maxdepth 1 -type d | grep -oP "./$path#\d+$" | grep -oP "#\d+" | sort -r))

keep=0
for r in ${olds[@]}; do
    if [[ $keep -lt $retain ]]; then
        ((++keep))
        continue
    fi
    echo rm -rf "$work$r"
done

