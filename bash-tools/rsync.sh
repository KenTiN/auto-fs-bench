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


# binaries
RSYNC_BINARY=`which rsync`
FDTREE_BINARY=`which fdtree.bash`
# if fdtree is in the PATH 
if [ -z "$FDTREE_BINARY" ]; then 
    FDTREE_BINARY=`which ./fdtree.bash`
fi

usage() {
    echo "$0: <mount point>"
    exit 0
}

[[ $# -lt 1 ]] && usage

[[ -z ${RSYNC_BINARY} ]] && echo "Can't find rsync." && exit -1
[[ -z ${FDTREE_BINARY} ]] && echo "Can't find fdtree." && exit -1

flog=${WORKING_DIR}/rsync_`date "+%Y%m%d_%Hh%Mm%Ss"`_`basename $1`.log
tmpd="/tmp/$$"

TESTDIR="$1/rsync_${HOSTNAME}_$$"
mkdir $TESTDIR
if [ 0 -ne $? ]; then
    usage
fi

mkdir $tmpd

echo "Begin fdtree: $(date +%d-%m-%Y--%H:%M:%S)" >> $flog
${FDTREE_BINARY} -C -l 3 -d 15 -f 15 -s 2 -o $tmpd 2>&1 | tee -a $flog
echo "End fdtree and begin rsync: $(date +%d-%m-%Y--%H:%M:%S)" >> $flog

(time ${RSYNC_BINARY} -avz $tmpd $TESTDIR) 2>&1 | tee -a $flog
echo "End rsync and Begin rm: $(date +%d-%m-%Y--%H:%M:%S)" >> $flog

(time rm -rf $TESTDIR) 2>&1 | tee -a $flog
echo "End rm: $(date +%d-%m-%Y--%H:%M:%S)" >> $flog

# Clean the log file (-v of rsync)
	sed -i '/LEVEL0/d' $flog

# Clean errors in the file
	echo "" >> $flog
    echo "--------------------------------------------------------------" >> $flog
    echo "Gestion des erreurs :" >> $flog
    # rm
        # timer
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^rm: cannot remove .*: Timer expired$/d' $flog
        echo "rm - Timer expired :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog

        # Autre 
        error=`grep -E "^rm: cannot remove " $flog | cut -d':' -f3 | sort -u`
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^rm: cannot remove /d' $flog
        echo "rm - autre erreur :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog
        echo "Type autre erreur :" $error >> $flog
        echo "" >> $flog


    # mkdir
        # timer
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^mkdir: cannot create directory .*: Timer expired$/d' $flog
        echo "mkdir - Timer expired :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog

        # Autre :
        error=`grep -E "^mkdir: cannot create directory " $flog | cut -d':' -f3 | sort -u`
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^mkdir: cannot create directory /d' $flog
        echo "mkdir - : autre erreur :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog
        echo "Type autre erreur :" $error >> $flog
        echo "" >> $flog

    # rmdir
        # Timer
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^rmdir: failed to remove .*: Timer expired$/d' $flog
        echo "rmdir - Timer expired :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog

        # Autre
        error=`grep -E "^rmdir: failed to remove " $flog | cut -d':' -f3 | sort -u`
        num=`wc -l $flog | cut -d' ' -f1`
        sed -i '/^rmdir: failed to remove /d' $flog
        echo "rmdir - autre erreur :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog
        echo "Type autre erreur :" $error >> $flog
        echo "" >> $flog

    # Autres erreurs
		num=`wc -l $flog | cut -d' ' -f1`
		sed -i '/Skipping any contents from this failed directory/d' $flog
		echo "Skipping any contents from this failed directory :" $(($num - `wc -l $flog | cut -d' ' -f1`)) >> $flog

# Suppressiond des dossiers de travail
rm -rf $tmpd
rm -rf $TESTDIR

exit 0
