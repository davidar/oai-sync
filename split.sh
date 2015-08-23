#!/bin/bash

CWD=`pwd`
DIR=`mktemp -d`
cd $DIR

csplit -b '%09d.xml' -f 'part-' - '/^<re/' '{*}' >/dev/null
cat part-000000001.xml
NUM=`ls part-*.xml | wc -l`
head -n1 `printf "part-%09d.xml" $(($NUM-1))`

for N in `seq 3 $(($NUM-2))`; do
    FILE=`printf "part-%09d.xml" $N`
    ID=`fgrep '<identifier>' $FILE | sed 's|.*<identifier>\(.*\)</identifier>|\1|' | tr ':._-' '/'`
    echo $ID
    mkdir -p $CWD/`dirname $ID`
    mv -f $FILE $CWD/$ID.xml
done

cd $CWD
rm -rf $DIR
