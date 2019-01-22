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

# If there is a "mysetup.sh" script in this directory it will run it after the
# other setup items, and arrange for it to be run in any login scripts later
# e.g. ssh logins
if test $# != 2; then
  echo You must supply 2 arguments to this script.
  echo Usage is: zynqmp_setup.sh '<ntp-server> <timezone>'
  echo A good example timezone is: EST5EDT,M3.2.0,M11.1.0
  echo If the ntp-server is '"-"', no ntpclient will be started.
else
  export OCPI_CDK_DIR=/home/root/opencpi
  # In case dhcp failed on eth0, try it on eth1
  if test "$1" != -; then
    echo Attempting to set the time from time server: $1
    if rdate $1; then
      echo Succeeded in setting the time from time server: $1
    else
      echo ====YOU HAVE NO NETWORK CONNECTION and NO HARDWARE CLOCK====
      echo Set the time using the '"date YYYY.MM.DD-HH:MM[:SS]"' command.
    fi
  fi
  # Make sure the hostname is in the host table
  myhostname=`hostname`
  if ! grep -q $myhostname /etc/hosts; then echo 127.0.0.1 $myhostname >> /etc/hosts; fi
  # Run the generic script to setup the OpenCPI environment
  # Note the ocpidriver load command is innocuous if run redundantly
  OCPI_CDK_DIR=/home/root/opencpi
  cat <<EOF > $HOME/.profile
    echo Executing $HOME/.profile.
    export OCPI_CDK_DIR=$OCPI_CDK_DIR
    if test -f /etc/opencpi-release; then
      read OCPI_TOOL_PLATFORM x < /etc/opencpi-release
    else
      #echo No /etc/opencpi-release - assuming zcu102 hardware
      #OCPI_TOOL_PLATFORM=zcu102
      echo No /etc/opencpi-release - assuming xilinx18_2 hardware
      OCPI_TOOL_PLATFORM=xilinx18_2
    fi
    export OCPI_TOOL_PLATFORM
    export OCPI_TOOL_OS=linux
    # There is no multimode support when running standalone
    export OCPI_TOOL_DIR=\$OCPI_TOOL_PLATFORM
    export OCPI_LIBRARY_PATH=$OCPI_CDK_DIR/\$OCPI_TOOL_DIR/artifacts
    export PATH=$OCPI_CDK_DIR/\$OCPI_TOOL_DIR/bin:\$PATH
    # This is only for explicitly-linked driver libraries.  Fixed someday.
    export LD_LIBRARY_PATH=$OCPI_CDK_DIR/\$OCPI_TOOL_DIR/lib:\$LD_LIBRARY_PATH
    ocpidriver load
    export TZ=$2
    echo OpenCPI ready for zynqmp.
    if test -r $OCPI_CDK_DIR/mysetup.sh; then
       source $OCPI_CDK_DIR/mysetup.sh
    fi
EOF
  echo Running login script. OCPI_CDK_DIR is now $OCPI_CDK_DIR.
  source $HOME/.profile
fi

