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

# Settings when targeting this platform
export OcpiLibraryPathEnv=DYLD_LIBRARY_PATH
export OcpiRpathOrigin=@executable_path
export OcpiDynamicSuffix=dylib
export OcpiDynamicFlags=-dynamiclib
# -install_name @rpath/$(notdir $@)
export OCPI_OCL_LIBS=-locpi_ocl -framework OpenCL
export OcpiAsNeeded=
export OCPI_EXPORT_DYNAMIC=-Xlinker -export_dynamic
export OCPI_DYNAMIC=1
#export OCPI_TARGET_CXXFLAGS+=-std=c++0x
export OCPI_HAVE_OPENCL=1
export OCPI_OPENCL_LIB=/System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL
#export OCPI_OPENCV_HOME=/opt/opencpi/prerequisites/opencv/macos-10.8-x86_64
