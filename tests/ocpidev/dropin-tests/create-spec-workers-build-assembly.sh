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

# AV-4130
# This test catches the bug in which specs are not exported
# in library if the library itself has not been built. The
# fix was to 'make speclinks -C ../' when building a worker.
set -e
if [ -n "$HDL_TEST_PLATFORM" ]; then
   sims=$HDL_TEST_PLATFORM
else
   sims=(`ocpirun -C --only-platforms | grep '.*-.*sim' | sed s/^.*-//`)
   [ -z "$sims" ] && {
       echo This test requires a simulator for building, and there are none so we are skipping it.
       exit 0
  }
  echo Available simulators are: ${sims[*]}, using $sims.
fi
echo Using sim platform: $sims
rm -r -f test
ocpidev create project test
cd test
ocpidev create library components
ocpidev create spec workerOne
ocpidev create spec workerTwo
echo -n '<ComponentSpec>
    <Port name="out" protocol="iqstream_protocol" producer="true"></Port>
</ComponentSpec>' > components/specs/workerOne-spec.xml
echo -n '<ComponentSpec>
    <Port name="in" protocol="iqstream_protocol"></Port>
</ComponentSpec>' > components/specs/workerTwo-spec.xml
ocpidev create worker workerOne.hdl
ocpidev create worker workerTwo.hdl
ocpidev create hdl assembly testassembly
echo -n '<HdlAssembly>
  <Instance Worker="workerOne"/>
  <Instance Worker="workerTwo"/>
  <Connection>
     <Port Instance="workerOne" Name="out"/>
     <Port Instance="workerTwo" Name="in"/>
  </Connection>
</HdlAssembly>' > hdl/assemblies/testassembly/testassembly.xml
(cd components/workerOne.hdl && ocpidev build --hdl-platform $sims)
(cd components/workerTwo.hdl && ocpidev build --hdl-platform $sims)
# When AV-4130 was encountered, this line is necessary in order to make things work:
#make exports
(cd hdl/assemblies/testassembly && ocpidev build --hdl-platform $sims)

cd ../;
ocpidev delete -f project test/
