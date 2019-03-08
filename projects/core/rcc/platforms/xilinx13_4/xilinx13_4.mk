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

##########################################################################################
# This file defines the xilinx13_4 software platform.
# It sets platform variables as necessary to override the defaults in the file:
#   include/platform-defaults.mk file.
# See that file for a description of valid variables and their defaults.

include $(dir $(lastword $(MAKEFILE_LIST)))../../../../core/rcc/platforms/xilinx13_3/xilinx13_3.mk
OcpiPlatformOs=linux
OcpiPlatformOsVersion=x13_4
OcpiPlatformArch=arm
OcpiPlatformPrerequisites=busybox:xilinx13_4 gdb:xilinx13_4 rsync:xilinx13_4 gpsd:xilinx13_4
