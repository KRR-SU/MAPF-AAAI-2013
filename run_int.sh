#!/bin/bash

variant=$1
test "x$variant" == x && { echo "please give variant!" ; exit -1; }
timeout=$2
test "x$timeout" == x && { echo "please give timeout!" ; exit -1; }
claspconfig=$3

MKTEMP="mktemp -t tmp.XXXXXXXXXX"
AUX=$($MKTEMP)

LASTLIMIT=0
for limit in 30 40 50 60 70 80; do
	LASTLIMIT=$limit
	runlim -s 4000 -k \
		./gringo --const k=$limit $variant $instance >$AUX 2>>$logbase.groundtime
	runlim -s 4000 -k \
		./clasp ${claspconfig} --time-limit=${timeout} $AUX >>$logbase.stdout 2>>$logbase.solvetime 
	if grep -q "^Optimization:" $logbase.stdout; then
		break
	fi
done
PATHLENGTH=`grep "^Optimization:" $logbase.stdout |tail -n 1 |sed 's/^Optimization:.*\([0-9]+\)$/\1/'`
echo "LASTLIMIT: $LASTLIMIT" >>$logbase.stdout
echo "PATHLENGTH: $PATHLENGTH" >>$logbase.stdout

