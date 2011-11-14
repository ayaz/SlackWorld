#!/bin/bash
#
# The Slack World, Issue #2, June 2005
# Updated for Slackware releases >=12.0 (no more spaces after package names)
#
# The script prepares Slackware tagfiles from the list of packages
# installed in the machine.  The script can be used in case one
# wants to install the same set of Slackware packages on another
# machine.  (Surely, there are other ways to implement the task.)
#
# The script was originally written by bmgz <bmg2x @ yahoo.com> and
# posted at alt.os.linux.slackware on Sun, 27 Feb 2005, see
#
# http://groups-beta.google.com/group/alt.os.linux.slackware/msg/7c6cc77fc61ea4d2
#
# and
#
# http://groups-beta.google.com/group/alt.os.linux.slackware/msg/441b40bd711ec3d6
#
# and slightly edited by Mikhail Zotov <slackworld at gmail com>.
#
# Before running the script, edit the DISKSETPATH variable below.
# This must be a path to a directory where the Slackware `tree'
# (i.e., directories a, ap, d, ... x, y) can be found together
# with the corresponding tagfiles.  One has to mount both CDs one
# after another if the second CD was used during installation and
# to run the script twice (i.e., once for each CD).
# 

#DISKSETPATH="/mnt/cdrom/slackware"

# Create a list of installed packages
echo -n "Creating list of installed packages... "

# Here we use rules which seem to work properly with both stock
# Slackware packages and those downloaded form linuxpackages.net.
# This is not needed for our purpose but it doesn't hurt.
# The list of installed packages can be used for other purposes, too.
#
# The first "sed" was suggested by James Michael Fultz in his posting
# http://groups-beta.google.com/group/alt.os.linux.slackware/msg/704e9c658aa2be9b?hl=en
#

ls /var/log/packages/* | sed 's/-[^-]\+-[^-]\+-[^-]\+$//' \
 | sed 's|/var/log/packages/||' > installed-packages.txt
echo "done!"

for PACKAGESET in $(ls $DISKSETPATH); do
  if [ -d $DISKSETPATH/$PACKAGESET ]; then
    echo -n "Generating tagfile for package set $PACKAGESET/ ... "

    if [ ! -d ./$PACKAGESET ]; then
      mkdir $PACKAGESET
    fi

    if [ ! -s ./$PACKAGESET/tagfile  ]; then
      cp $DISKSETPATH/$PACKAGESET/tagfile ./$PACKAGESET/tagfile
    fi

    cat ./$PACKAGESET/tagfile | egrep -v ^\# | sed 's/:.../:SKP/' \
      > ./$PACKAGESET/tagfile

    while read PACKAGE ; do
      if [ $(grep -c $PACKAGE ./$PACKAGESET/tagfile) -gt 0 ]; then
        sed "s/$PACKAGE:SKP/$PACKAGE:ADD/;w $PACKAGESET/tagfile.tmp" \
          $PACKAGESET/tagfile 1> /dev/null
        cp ./$PACKAGESET/tagfile.tmp ./$PACKAGESET/tagfile
      fi
    done < installed-packages.txt
    echo "done!"
  fi
done
find . -name tagfile.tmp | xargs rm
# EOF
