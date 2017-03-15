#!/bin/bash

#
# The "Fuck Jack Build Script"
#
# Written by Michael S Corigliano (Mike Criggs) (michael.s.corigliano@gmail.com)
# Improved by axxx007xxxz
#
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#
#
# The purpose of this script is to work around JACK and NINJA, which have been
# broken in AOSP as of android-7.0.
#
# Usage: ./build_xenonhd.sh <DEVICE>
#

function killjack {
	./prebuilts/sdk/tools/jack-admin kill-server
}

function restartjack {
	killjack
	./prebuilts/sdk/tools/jack-admin start-server
}

function build {
	if [[ $SYNC == true ]]; then repo sync --force-sync -f -c -j4; fi
	lunch xenonhd_${1}-userdebug
	mka bacon
}

function buildagain {
	for files in out/target/product/${1}/*.zip; do
	        if [ ! -e $files ]; then restartjack || build $1; fi
	done
}


# Optionally, you may want to sync the repo
#	SYNC=true

# Tell the environment not to use NINJA
	export USE_NINJA=false

# Resize the Java Heap size
	export _JAVA_OPTIONS="-Xmx4096m"

# Optionally, you may want to delete the JACK server located in /home/<USER>/.jack*
#	rm -fr ~/.jack*

# Resize the JACK Heap size
	export ANDROID_JACK_VM_ARGS="-Xmx1024m -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

# Restart the JACK server
	restartjack

# Optionally, you may want to clear CCACHE if you still have issues
#	ccache -C

# Optionally, you may want to make a clean build, building dirty after you have had jack issues may result in a failed build
#	make clobber

# Compile the build
	. build/envsetup.sh
	build $1	

# Optionally, you may want to build again if the build failed
#	buildagain $1
#	buildagain $1
#	buildagain $1
#	buildagain $1

# Kill JACK
	killjack
