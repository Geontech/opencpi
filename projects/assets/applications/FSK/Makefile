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

# This file is used to build the Application Control Interface api testbench and
# is used to run the respective application. This file handles hardware workers
# and has been tested on the Matchstiq-Z1 platform.

$(if $(realpath $(OCPI_CDK_DIR)),,$(error The OCPI_CDK_DIR environment variable is not set correctly.))

include $(OCPI_CDK_DIR)/include/application.mk

.SILENT: show
.PHONY: show

all: tap_gen

idata/tx_rrcos_taps.dat idata/rx_rrcos_taps.dat: tap_gen

tap_gen:
	$(eval numTaps=128)
	$(eval alpha=0.95)
	$(eval baudRate=64000)
	$(eval spb=39)
	$(eval maxTap=4096)
	# Remove old test data files
	rm -rf idata/*.dat idata/*.bin odata/*
	# Create test input data
	python scripts/gen_rrcos_taps.py $(numTaps) $(alpha) `echo "1/$(baudRate)" | bc -l` `echo "$(baudRate)*$(spb)" | bc -l` $(maxTap) idata/tx_rrcos_taps.dat
	python scripts/gen_rrcos_taps.py $(numTaps) $(alpha) `echo "1/$(baudRate)" | bc -l` `echo "$(baudRate)*$(spb)" | bc -l` $(maxTap) idata/rx_rrcos_taps.dat

clean::
	rm -rf idata/*.dat idata/*.bin odata/* scripts/*.pyc

show:
	echo "$$showhelp"

define showhelp
----------------------------------------------------------------------------
----------------------------------------------------------------------------
The instructions below are used to test the various mode of the FSK
application on a remote platform like the Matchstiq-Z1 or Zedboard/Zipper.
The FSK application has five modes of operation: filerw, rx, tx, txrx, bbloopback.
Each has been giving a test '#', that must be followed for execution on a
remote system and, subsequent verification of the output data on the development system.
Test 1: filerw - Application Workers only in loopback mode (no RF; no device workers)
Test 2: rx - receive only
Test 3: tx - transmit only
Test 4: txrx - transmit and receive (may use COAX cable for loopback)
Test 5: bbloopback - TX/RX with baseband loopback path of the transceiver device

There are four steps for executing a test:
1) Build ACI and/or input test data (development system)
2) Setup the OCPI_LIBRARY_PATH (remote system)
3) Execution of application (remote system)
4) Verification of output data (development system)
----------------------------------------------------------------------------
1) Build ACI and/or input test data: (development system)
NOTE: Required only if ACI has never been built.
ocpidev build --rcc-platform xilinx13_3
or
ocpidev build --rcc-platform xilinx13_4
or
----------------------------------------------------------------------------
2) Setup the OCPI_LIBRARY_PATH: (remote system)
IMPORTANT NOTE: this guide assumes you are operating in NFS/Network mode on the
radio and you have your projects mounted at:
/mnt/ocpi_core and /mnt/ocpi_assets

NOTE: Reminder to setup the run-time OCPI environment on remote system.
. /mnt/card/opencpi/mynetsetup.sh {DEVELOPMENT HOST IPADDRESS}

NOTE: Convenience cmd to quickly switch to application directory.
cd /mnt/ocpi_assets/applications/FSK

REQUIRED - Reconfigure to default. 'Common' export string for all Tests.
Copy/paste string to terminal of remote system:
export OCPI_LIBRARY_PATH=/mnt/ocpi_core/artifacts:$$(pwd)/../../artifacts

REQUIRED - Configure per FSK mode of operation. 'Unique' export string for each Test.
Copy/paste command to terminal of remote system:
Test 1:
export OCPI_LIBRARY_PATH=$$(pwd)/../../artifacts/fsk_filerw:$$OCPI_LIBRARY_PATH
Test 2:
export OCPI_LIBRARY_PATH=$$(pwd)/../../artifacts/dc_offset_iq_imbalance_mixer_cic_dec_rp_cordic_fir_real:$$OCPI_LIBRARY_PATH
Test 3:
export OCPI_LIBRARY_PATH=$$(pwd)/../../artifacts/mfsk2_zp16_fir_real_phase_to_amp_cordic_cic_int:$$OCPI_LIBRARY_PATH
Test 4:
export OCPI_LIBRARY_PATH=$$(pwd)/../../artifacts/fsk_modem:$$OCPI_LIBRARY_PATH
Test 5:
export OCPI_LIBRARY_PATH=$$(pwd)/../../artifacts/fsk_modem:$$OCPI_LIBRARY_PATH

NOTE: We could be more narrow with these search paths, but it is unnecessary
for Zynq-Based platforms because each assembly only has a single container
that will work for a given test mode.

----------------------------------------------------------------------------
3) Execution of application: (remote system)
Test 1: ./target-xilinx13_3/FSK filerw
Test 2: ./target-xilinx13_3/FSK rx
Test 3: ./target-xilinx13_3/FSK tx
Test 4: ./target-xilinx13_3/FSK txrx
Test 5: ./target-xilinx13_3/FSK bbloopback
----------------------------------------------------------------------------
4) Verification of output data: (development system)
Test 1: eog odata/out_app_fsk_filerw.bin &
Test 2: eog odata/out_app_fsk_rx.bin &
Test 3: Visually inspect the spectrum on a spectrum analyzer.
Test 4: eog odata/out_app_fsk_txrx.bin &
Test 5: eog odata/out_app_fsk_bbloopback.bin &
----------------------------------------------------------------------------
----------------------------------------------------------------------------
endef
export showhelp
