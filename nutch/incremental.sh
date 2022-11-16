#!/bin/bash

echo $1

NUTCH_HOME=/opt/nutch/$1

echo $NUTCH_HOME

touch $NUTCH_HOME/timecounter

TIME_FILE=$NUTCH_HOME/timecounter

$NUTCH_HOME/bin/nutch inject $NUTCH_HOME/crawl/crawldb $NUTCH_HOME/urls

while :
do
$NUTCH_HOME/bin/nutch generate $NUTCH_HOME/crawl/crawldb $NUTCH_HOME/crawl/segments
s1=`ls -d $NUTCH_HOME/crawl/segments/2* | tail -1`
$NUTCH_HOME/bin/nutch fetch $s1
if [ $? -ne 0 ]
      then
      break
fi
$NUTCH_HOME/bin/nutch parse $s1

$NUTCH_HOME/bin/nutch updatedb $NUTCH_HOME/crawl/crawldb $s1

done

$NUTCH_HOME/bin/nutch invertlinks $NUTCH_HOME/crawl/linkdb -dir $NUTCH_HOME/crawl/segments


for dir in $NUTCH_HOME/crawl/segments/*; do
           if [ $(date +%s -r $dir) -gt $(date +%s -r $TIME_FILE) ]; then
           $NUTCH_HOME/bin/nutch index $NUTCH_HOME/crawl/crawldb/ -linkdb $NUTCH_HOME/crawl/linkdb/ $dir -filter -normalize -deleteGone

           fi
done
