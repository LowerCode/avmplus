#!/bin/bash
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.
(set -o igncr) 2>/dev/null && set -o igncr; # comment is needed


##
# Bring in the environment variables
##
. ./environment.sh


##
# Calculate the change number and change id
##
. ../all/util-calculate-change.sh $1


##
# Download the AVMSHELL if it does not exist
##
download_shell $shell_selftest

##
# Ensure that the system is clean and ready
##
cd $basedir/build/buildbot/slaves/scripts
../all/util-acceptance-clean.sh

AVM=$buildsdir/$change-${changeid}/$platform/$shell_selftest

$AVM -Dselftest > selftest.out 2>&1
ret=$?

cat selftest.out

passes=`grep pass selftest.out | wc -l`
fails=`grep fail selftest.out | wc -l`

# a non-zero exit code indicates an avm crash, therefore increment the failures by 1
if [ "$ret" -ne "0" ]; then
    let fails=fails+1
fi

echo "passes            : $passes"
echo "failures          : $fails"

rm selftest.out

##
# Ensure that the system is torn down and clean
##
cd $basedir/build/buildbot/slaves/scripts
../all/util-acceptance-teardown.sh

exit $ret
 
