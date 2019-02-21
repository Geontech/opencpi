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

puts "Generating wrapper verilog file for PS8 from the  zynq_ultra_ps_e IP"
create_project managed_ip_project managed_ip_project -part xczu9eg-ffvb1156-2-e -ip -force;
# TODO: Could use get_parts -filter {FAMILY == zynquplus}, but there does not appear to be a way
#       to determine which zynquplus parts are usable/licensed with the current installation.

set_property target_language VHDL [current_project];

# Create the IP for the PS8 wrapper - let the tool choose the version
create_ip -name zynq_ultra_ps_e -vendor xilinx.com -library ip -module_name zynq_ultra_ps_e_0;

# Configure the PS IP for AXI width 32 for the PS master and 64 for the PS slave
# Use MAXIGP0-1 and SAXIGP2-5
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__MAXIGP0__DATA_WIDTH {32} CONFIG.PSU__USE__M_AXI_GP1 {1} CONFIG.PSU__MAXIGP1__DATA_WIDTH {32} CONFIG.PSU__USE__M_AXI_GP2 {0} CONFIG.PSU__USE__S_AXI_GP2 {1} CONFIG.PSU__SAXIGP2__DATA_WIDTH {64} CONFIG.PSU__USE__S_AXI_GP3 {1} CONFIG.PSU__SAXIGP3__DATA_WIDTH {64} CONFIG.PSU__USE__S_AXI_GP4 {1} CONFIG.PSU__SAXIGP4__DATA_WIDTH {64} CONFIG.PSU__USE__S_AXI_GP5 {1} CONFIG.PSU__SAXIGP5__DATA_WIDTH {64} CONFIG.PSU__DDRC__ENABLE {0}] [get_ips zynq_ultra_ps_e_0];

# Generate IP files which will be used by OpenCPI
generate_target all [get_files managed_ip_project/managed_ip_project.srcs/sources_1/ip/zynq_ultra_ps_e_0/zynq_ultra_ps_e_0.xci];

set ip [get_ips zynq_ultra_ps_e_0]
# Get this IP core's version (e.g 3.2)
set major_version [get_property VERSION [get_ipdefs xilinx.com:ip:zynq_ultra_ps_e*]]
# Core revision is the minor-version
set minor_version [get_property CORE_REVISION $ip]
# This version will be part of the filename for the PS8 wrapper (e.g. zynq_ultra_ps_e_v3_2_1)
# So, replace the '.' characters separating version digits with underscores
set file_version [regsub {\.} $major_version "_"]_$minor_version

# Copy the wrapper for the PS8 primitive out of this tmp/ directory for use by OpenCPI
set ps8_wrapper_file managed_ip_project/managed_ip_project.srcs/sources_1/ip/zynq_ultra_ps_e_0/hdl/zynq_ultra_ps_e_v${file_version}.v
file copy $ps8_wrapper_file ../zynq_ultra_ps_e_ps8_wrapper.v

# This file wraps the zynq_ultra_ps_e IP after applying the configurations set above
# Copy the zynq_ultra_ps_e IP wrapper out of this tmp/ directory for use by OpenCPI
file copy managed_ip_project/managed_ip_project.srcs/sources_1/ip/zynq_ultra_ps_e_0/synth/zynq_ultra_ps_e_0.vhd ../
