#!/bin/bash

#  Copyright (c) 2010 Fizians SAS. <http://www.fizians.com>
#  This file is part of Rozofs.
#  Rozofs is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
#  by the Free Software Foundation, version 2.
#  Rozofs is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see
#  <http://www.gnu.org/licenses/>.

WORKING_DIR=$PWD
FSOP_BINARY=`which fileop`

usage() {
    echo "$0: <mount point>"
    exit 0
}

[[ $# -lt 1 ]] && usage

[[ -z ${FSOP_BINARY} ]] && echo "Can't find fileop." && exit -1

TESTDIR="$1/fileop_${HOSTNAME}_$$"
mkdir $TESTDIR
if [ 0 -ne $? ]; then
    usage
fi

flog=${WORKING_DIR}/fileop_`date "+%Y%m%d_%Hh%Mm%Ss"`_`basename $1`.log
${FSOP_BINARY} -l 1 -u 10 -i 1 -s 1M -d $TESTDIR 2>&1 | tee $flog
# ${FSOP_BINARY} -l 1 -u 5 -i 1 -s 1M -d $TESTDIR 2>&1 | tee $flog # light test

rm -rf $TESTDIR

# Clean the log file
sed -i "s/\ \ */\ /g" $flog
mv $flog ${flog}.csv

exit 0
