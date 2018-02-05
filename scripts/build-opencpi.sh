#!/bin/sh
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of OpenCPI <http://www.opencpi.org>
#
# OpenCPI is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# OpenCPI is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

set -e
if test "$OCPI_CDK_DIR" != ""; then
  echo Since OCPI_CDK_DIR is set, we will use the existing environment.
  if test "$1" != ""; then
   if test -n "$OCPI_TARGET_PLATFORM" -a "$1" != "$OCPI_TARGET_PLATFORM"; then
      echo Error: supplied platform $1 is different from the environment: $OCPI_TARGET_PLATFORM
      exit 1
   fi
   export OCPI_TARGET_PLATFORM=$1
  fi
else
  export OCPI_TARGET_PLATFORM=$1
  # Initialize access to the core tree's export directory
  source scripts/core-init.sh
  # Initialize access to CDK
  OCPI_BOOTSTRAP=`pwd`/exports/scripts/ocpibootstrap.sh; source $OCPI_BOOTSTRAP
  [ -z "$OCPI_TARGET_PLATFORM" ] && export OCPI_TARGET_PLATFORM=$OCPI_TOOL_PLATFORM
fi
echo ================================================================================
echo We are running in `pwd` where the git clone of opencpi has been placed.
echo ================================================================================
echo Now we will '"make"' the OpenCPI framework libraries and utilities for $OCPI_TARGET_PLATFORM
make
echo ================================================================================
echo Now we will '"make"' the built-in RCC '(software)' components for $OCPI_TARGET_PLATFORM
make -C projects/core rcc
make -C projects/assets rcc
make -C projects/inactive rcc
echo ================================================================================
echo Now we will '"make"' the built-in OCL '(GPU)' components for the available OCL platforms
make -C projects/core ocl
make -C projects/assets ocl
make -C projects/inactive ocl
echo ================================================================================
echo Now we will '"make"' the examples for $OCPI_TARGET_PLATFORM
make -C projects/assets applications
make -C projects/inactive applications
echo ================================================================================
echo Finally, we will built the OpenCPI kernel device driver for $OCPI_TARGET_PLATFORM
make driver
echo ================================================================================
echo OpenCPI has been built for $OCPI_TARGET_PLATFORM, with software components, examples and kernel driver
trap - ERR
