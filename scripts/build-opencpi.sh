#!/bin/sh
set -e
if test "$OCPI_BASE_DIR" != ""; then
  echo Since OCPI_BASE_DIR is set, we will use the existing environment.
  if test "$1" != ""; then
   if "$1" != "$OCPI_TARGET_PLATFORM"; then
      echo Error: supplied platform $1 is different from the environment: $OCPI_TARGET_PLATFORM
      exit 1
   fi
  fi
else
  # We're being run in an uninitialized environment
  if test ! -d env -o ! -d platforms; then
    echo It appears that this script is not being run at the top level of OpenCPI.
    exit 1
  fi
  if test "$1" != ""; then
    echo Supplied cross-platform is $1.
    if test -d platforms/$1; then
     source env/default-cross.sh $1
     test $? = 0 || exit 1; 
    else
     echo Error: $1 is not a supported platform.
     exit 1
    fi
  else
    source env/default-env.sh
    test $? = 0 || exit 1; 
  fi
fi
echo ================================================================================
echo We are running in `pwd` where the git clone of opencpi has been placed.
echo ================================================================================
echo Now we will '"make"' the core OpenCPI libraries and utilities for $OCPI_TARGET_PLATFORM
make
echo ================================================================================
echo Now we will '"make"' the built-in RCC '(software)' components for $OCPI_TARGET_PLATFORM
make rcc
echo ================================================================================
echo Now we will '"make"' the examples for $OCPI_TARGET_PLATFORM
make examples
echo ================================================================================
echo Finally, we will built the OpenCPI kernel device driver for $OCPI_TARGET_PLATFORM
make driver
echo ================================================================================
echo OpenCPI has been built for $OCPI_TARGET_PLATFORM, with software components, examples and kernel driver
trap - ERR