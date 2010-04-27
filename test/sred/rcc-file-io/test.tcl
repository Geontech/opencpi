#! /bin/sh
# Copyright (c) 2009 Mercury Federal Systems.
# 
# This file is part of OpenCPI.
# 
# OpenCPI is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# OpenCPI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with OpenCPI.  If not, see <http://www.gnu.org/licenses/>.

#
# ----------------------------------------------------------------------
# Test script for the CPI SCA RCC Executable Device using a "File I/O"
# test application.
#
# Revision History:
#
#     06/03/2009 - Frank Pilhofer
#                  Initial version.
#
# ----------------------------------------------------------------------
#
# \
export LD_LIBRARY_PATH=$ACE_ROOT/lib:$LD_LIBRARY_PATH
# the next line restarts using tclsh \
exec tclsh8.5 "$0" ${1+"$@"}

#
# /opt/local/TAO/5.6.6/linux-x86_64-gcc/ACE_wrappers/TAO/orbsvcs/Naming_Service/Naming_Service -ORBEndPoint iiop://:4332
# /h/fpilhofe/soft/cpi/core/sca/sred/linux-bin/cpi-rcc-exec-device -ORBInitRef NameService=corbaloc::localhost:4332/NameService --identifier RCCed --label RCCed --cpiDeviceId=42 --endpoint=cpi-smb-pio://FPSMB:1048576.1.2 --writeIORFile=- --logFile=- --polled --registerWithNamingService=RCCed --defaultBufferSize=1024
# /h/fpilhofe/soft/cpi/core/sca/gpped/linux-bin/cpi-gpp-exec-device -ORBInitRef NameService=corbaloc::localhost:4332/NameService --label=GPPed --identifier=GPPed --cpiDeviceId=46 --writeIORFile=- --logFile=- --registerWithNamingService=GPPed
#

lappend auto_path \
	$env(CPIDIR)/tools/tcl/combat \
	$env(CPIDIR)/tools/tcl/cfutil \
	$env(CPIDIR)/tools/tcl/tclkill
package require vfs
package require vfs::zip
package require cfutil
package require kill

set autoStart [expr {[llength $argv] ? 0 : 1}]
set testDir [file normalize [file dirname [info script]]]
set appFile [file join $testDir $env(OUTDIR) FileCopy.zip]

if {![file exists $appFile]} {
    #
    # Application was not built for this platform.  Skip test.
    #

    puts "$appFile not found."
    exit 2
}

if {$autoStart} {
    set nsPid [exec $env(TAO_ROOT)/orbsvcs/Naming_Service/Naming_Service -ORBEndPoint iiop://:4332 &]
    after 3000
    set sredPid [exec $env(CPIDIR)/core/sca/sred/$env(OUTDIR)/cpi-rcc-exec-device \
		     -ORBInitRef NameService=corbaloc::localhost:4332/NameService \
		     --identifier RCCed --label RCCed --defaultBufferSize=4096 \
		     --cpiDeviceId=42 --endpoint=cpi-smb-pio://fp-test:1048576.1.2 \
		     --writeIORFile=- --logFile=- --polled \
		     --registerWithNamingService=RCCed &]
    set gppedPid [exec $env(CPIDIR)/core/sca/gpped/$env(OUTDIR)/cpi-gpp-exec-device \
		      -ORBInitRef NameService=corbaloc::localhost:4332/NameService \
		      --label=GPPed --identifier=GPPed --cpiDeviceId=46 \
		      --writeIORFile=- --logFile=- \
		      --registerWithNamingService=GPPed &]
    after 3000
    set ncIor "corbaloc::localhost:4332/NameService"
} else {
    set ncIor [lindex $argv 0]
}

set sourceFile [file join $testDir Makefile]

if {[file isdirectory /tmp]} {
    set teeFile [file join /tmp CopyOfMakefile1]
    set sinkFile [file join /tmp CopyOfMakefile2]
} else {
    set teeFile [file join $testDir CopyOfMakefile1]
    set sinkFile [file join $testDir CopyOfMakefile2]
}

if {[catch {
    set nc [corba::string_to_object $ncIor]
    set eds [cfutil::findExecutableDevicesInNamingContext $nc]
    set sad "FileCopy.sad.xml"

    set zipMount "/zip"
    set zipFd [vfs::zip::Mount $appFile $zipMount]
    set sadFile [file join $zipMount $sad]

    set af [cfutil::ApplicationFactory \#auto $eds $sadFile 1]
    set app [$af create Foo]

    $app configure \
	[list \
	     [list id Source.fileName value [list string $sourceFile]] \
	     [list id Tee.fileName value [list string $teeFile]] \
	     [list id Sink.fileName value [list string $sinkFile]]]
    $app start

    puts "Letting the application run for a while ..."
    after 5000
    puts "done."

    $app stop
    $app releaseObject
    itcl::delete object $af

    vfs::zip::Unmount $zipFd $zipMount

    if {$autoStart} {
	foreach ed $eds {
	    $ed releaseObject
	}

	after 1000

	catch {kill $sredPid}
	catch {kill $gppedPid}
	kill $nsPid
    }

    catch {file delete /dev/shm/fp-test}

    #
    # Compare the original file with its copies.
    #

    set f [open $sourceFile]
    fconfigure $f -translation binary
    set sourceData [read $f]
    close $f

    set f [open $teeFile]
    fconfigure $f -translation binary
    set teeData [read $f]
    close $f

    set f [open $sinkFile]
    fconfigure $f -translation binary
    set sinkData [read $f]
    close $f

    if {[string compare $sourceData $teeData] != 0} {
	puts "Data in $teeFile mismatch."
	exit 1
    }

    if {[string compare $sourceData $sinkData] != 0} {
	puts "Data in $sinkFile mismatch."
	exit 1
    }

    file delete $teeFile
    file delete $sinkFile
} errMsg]} {
    set savedInfo $::errorInfo
    if {$autoStart} {
	catch {kill $sredPid}
	catch {kill $gppedPid}
	catch {kill $nsPid}
    }
    catch {file delete /dev/shm/fp-test}
    catch {file delete $teeFile}
    catch {file delete $sinkFile}
    error $errMsg $savedInfo
}
