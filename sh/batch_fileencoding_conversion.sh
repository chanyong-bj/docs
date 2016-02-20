#!/bin/bash

DIR=$1 # target files directory
FT=$2 # suffix of target file name
SE=$3 # FROM encoding
DE=$4 # TO encoding

for file in `find $DIR -type f -name "*.$FT"`; do
    echo "conversion $file encoding $SE to $DE"
    iconv -f $SE -t $DE "$file" > "$file".tmp
    mv -f "$file".tmp "$file"
done
