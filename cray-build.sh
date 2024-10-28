#!/bin/bash
#
#  This script builds ACK for the Cray X-MP computer running
#  the COS operating system. The COS Tools from the folling
#  GitHub repository must be built, installed, and accessible
#  via the PATH variable before running this script:
#
#    https://github.com/kej715/COS-Tools
#
#  In addition, when building on MacOS, true gcc must be
#  installed because ACK will not build successfully using
#  LLVM. Change the setting of the CC variable, below, as
#  needed to correspond with the version of gcc installed.
#
#  To build ACK:
#
#    ./cray-build.sh
#
#  To install it:
#
#    sudo ./cray-build.sh install
#
if [[ "$OSTYPE" == "darwin"* ]]; then
  export CC=gcc-13
else
  export CC=gcc
fi
__crayxmp=1 __cos=1 CRAYXMP_COS=1 gmake $*
