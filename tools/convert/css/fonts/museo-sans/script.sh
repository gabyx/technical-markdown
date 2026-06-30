#!/usr/bin/env bash

sed -n -E "s/.*'(MuseoSans-\w+\.woff2)'.*/\1/p" museo-sans.css | xargs -P 4 -n 1 -I {} bash -c "base64 -w 0 {} >{}.dat "

cp museo-sans.css museo-sans-mod.css

for file in ./*.dat; do
    echo "$file"
    base64=$(cat "$file")
    fileName=$(basename "$file" | sed -E "s/(.*)\.dat/\1/")
    sed -i -E "s@'$fileName'@'data:application/font-woff2;charset=utf-8;base64,$base64'@" museo-sans-mod.css
done

cp museo-sans-mod.css ../museo-sans.css
