#!/bin/bash --noprofile
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


# this script creates an installable tar.gz file for installing the build framework and
# built projects somewhere else for running sandboxed.  The biggest limitation is that
# it "exports" the projects as well as the framework so you need to have built everything
# for all the platforms you care about before exporting.
# An alternative option would be to export the source projects.
if [ `uname -s` = Darwin ]; then
  xf="-s "
else
  xf="--transform=s"
fi
set -e
file=opencpi-cdk-`date +%G%m%d%H%M%S`.tar
exfile=`mktemp -d -t ocpi_export.XXXXX`/$file.exclude
# For framework exports, we want to follow links since there is little or no redundancy.
find cdk ! -path 'cdk/imports/*' -follow -type l > $exfile
if [ -s $exfile ] ; then
  echo ==== These symlinks are broken for the CDK part of the export
  cat $exfile
  echo ==== End of broken symlinks
fi
echo 'cdk/imports/*' >> $exfile
# Follow links, but exclude busted links and imports
tar -h -f $file -c -X $exfile $xf'=^=opencpi/=' cdk system.xml prerequisites
# Add the registry, not following links
tar -f $file -r $xf'=^=opencpi/=' project-registry
# Do projects, using exports
shopt -s nullglob
for p in projects/*; do
  # Follow links on all exports but rcc platforms
  (cd $p/exports && find . -name imports -prune -o -follow -type l) > $exfile
  if [ -s $exfile ] ; then
    echo ==== These symlinks are broken for the $p/exports part of the export
    cat $exfile
    echo ==== End of broken symlinks
  fi
  tar -h -f $file -r -C $p/exports -X $exfile --exclude "./imports*" --exclude "*/rcc/platforms/*" \
	 $xf"=^./=opencpi/$p/=" .
  # export rcc platforms without following links since they are all local
  for r in $p/exports/lib/rcc/platforms/*; do
    tar -f $file -r $xf"=^$p/=opencpi/$p/lib/=" $p/rcc/platforms/$(basename $r)
  done
done
gzip $file
echo Exportable file created in $file.gz
echo It contains the projects in built form, disabling building them for other targets.



