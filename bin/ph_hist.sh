set -euo pipefail


dt=$(date +%y%m%d)
dt1=$(date +%y%m%d%H%M%S)


for path in "$@"
do
    in="${PH_IN}/$path"
    test -d "$in" || continue

    out="${PH_HIST}/$path"
    odt="${PH_HIST}/$path#$dt" # out snapshot with dt
    test ! -d "$odt" || odt="${PH_HIST}/$path#$dt1" # include time info folder name if already exists

    echo '#' Create snapshot directory
    echo mkdir -p "$odt"
    echo '#' Create latest directory
    echo mkdir -p "$out"

    echo
    echo '#' Rsync into latest
    echo rsync -a -L --delete-after --link-dest="$(realpath $in)"/  "$in"/ "$out"/
    echo '#' Rsync into new snapshot, keep link to latest
    echo rsync -a --link-dest="$out" "$out"/ "$odt"/
done

