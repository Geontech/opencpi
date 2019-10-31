-- This file is protected by Copyright. Please refer to the COPYRIGHT file
-- distributed with this source distribution.
--
-- This file is part of OpenCPI <http://www.opencpi.org>
--
-- OpenCPI is free software: you can redistribute it and/or modify it under the
-- terms of the GNU Lesser General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- OpenCPI is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

-- This file contains axi-specific definitions
-- While some of these interfaces are zynq-specific, they are here to manage dependencies better.
-- This will also enable moving toward more generic axi definitions.
-- If we used more recent VHDL we would have parameterized packages...

library IEEE; use IEEE.std_logic_1164.all; use ieee.numeric_std.all;
library ocpi; use ocpi.types.all;
library platform; use platform.platform_pkg.all;
package axi_pkg is

constant C_AXI_ADDR_WIDTH      : natural := 32; -- pinned at 32 in the AXI spec.
constant C_M_AXI_GP_ID_WIDTH   : natural := 12;
constant C_S_AXI_GP_ID_WIDTH   : natural := 6;
constant C_S_AXI_GP_COUNT      : natural := 2;
constant C_M_AXI_GP_COUNT      : natural := 2;
-- Inputs to the s_axi_gp port of the PS
type s_axi_gp_in_t is record
  ACLK    : std_logic;
  ARVALID : std_logic;
  AWVALID : std_logic;
  BREADY  : std_logic;
  RREADY  : std_logic;
  WLAST   : std_logic;
  WVALID  : std_logic;
  ARBURST : std_logic_vector(1 downto 0);
  ARLOCK  : std_logic_vector(1 downto 0);
  ARSIZE  : std_logic_vector(2 downto 0);
  AWBURST : std_logic_vector(1 downto 0);
  AWLOCK  : std_logic_vector(1 downto 0);
  AWSIZE  : std_logic_vector(2 downto 0);
  ARPROT  : std_logic_vector(2 downto 0);
  AWPROT  : std_logic_vector(2 downto 0);
  ARADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  AWADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  WDATA   : std_logic_vector(31 downto 0);
  ARCACHE : std_logic_vector(3 downto 0);
  ARLEN   : std_logic_vector(3 downto 0);
  ARQOS   : std_logic_vector(3 downto 0);
  AWCACHE : std_logic_vector(3 downto 0);
  AWLEN   : std_logic_vector(3 downto 0);
  AWQOS   : std_logic_vector(3 downto 0);
  WSTRB   : std_logic_vector(3 downto 0);
  ARID    : std_logic_vector(C_S_AXI_GP_ID_WIDTH-1 downto 0);
  AWID    : std_logic_vector(C_S_AXI_GP_ID_WIDTH-1 downto 0);
  WID     : std_logic_vector(C_S_AXI_GP_ID_WIDTH-1 downto 0);
end record s_axi_gp_in_t;
type s_axi_gp_in_array_t is array (natural range <>) of s_axi_gp_in_t;
-- Outputs from the s_axi_gp port of the PS
type s_axi_gp_out_t is record
  ARESETN : std_logic;
  ARREADY : std_logic;
  AWREADY : std_logic;
  BVALID  : std_logic;
  RLAST   : std_logic;
  RVALID  : std_logic;
  WREADY  : std_logic;
  BRESP   : std_logic_vector(1 downto 0);
  RRESP   : std_logic_vector(1 downto 0);
  RDATA   : std_logic_vector(31 downto 0);
  BID     : std_logic_vector(C_S_AXI_GP_ID_WIDTH-1 downto 0);
  RID     : std_logic_vector(C_S_AXI_GP_ID_WIDTH-1 downto 0);
end record s_axi_gp_out_t;
type s_axi_gp_out_array_t is array (natural range <>) of s_axi_gp_out_t;
-- Inputs to the m_axi_gp port of the PS
type m_axi_gp_in_t is record
  ACLK    : std_logic;
  ARREADY : std_logic;
  AWREADY : std_logic;
  BVALID  : std_logic;
  RLAST   : std_logic;
  RVALID  : std_logic;
  WREADY  : std_logic;
  BID     : std_logic_vector(C_M_AXI_GP_ID_WIDTH-1 downto 0);
  RID     : std_logic_vector(C_M_AXI_GP_ID_WIDTH-1 downto 0);
  BRESP   : std_logic_vector(1 downto 0);
  RRESP   : std_logic_vector(1 downto 0);
  RDATA   : std_logic_vector(31 downto 0);
end record m_axi_gp_in_t;
type m_axi_gp_in_array_t is array (natural range <>) of m_axi_gp_in_t;
-- Outputs from the m_axi_gp port of the PS into the PL
type m_axi_gp_out_t is record
  ARESETN : std_logic;
  ARVALID : std_logic;
  AWVALID : std_logic;
  BREADY  : std_logic;
  RREADY  : std_logic;
  WLAST   : std_logic;
  WVALID  : std_logic;
  ARID    : std_logic_vector(C_M_AXI_GP_ID_WIDTH-1 downto 0);
  AWID    : std_logic_vector(C_M_AXI_GP_ID_WIDTH-1 downto 0);
  WID     : std_logic_vector(C_M_AXI_GP_ID_WIDTH-1 downto 0);
  ARBURST : std_logic_vector(1 downto 0);
  ARLOCK  : std_logic_vector(1 downto 0);
  ARSIZE  : std_logic_vector(2 downto 0);
  AWBURST : std_logic_vector(1 downto 0);
  AWLOCK  : std_logic_vector(1 downto 0);
  AWSIZE  : std_logic_vector(2 downto 0);
  ARPROT  : std_logic_vector(2 downto 0);
  AWPROT  : std_logic_vector(2 downto 0);
  ARADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  AWADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  WDATA   : std_logic_vector(31 downto 0);
  ARCACHE : std_logic_vector(3 downto 0);
  ARLEN   : std_logic_vector(3 downto 0);
  ARQOS   : std_logic_vector(3 downto 0);
  AWCACHE : std_logic_vector(3 downto 0);
  AWLEN   : std_logic_vector(3 downto 0);
  AWQOS   : std_logic_vector(3 downto 0);
  WSTRB   : std_logic_vector(3 downto 0);
end record m_axi_gp_out_t;
type m_axi_gp_out_array_t is array (natural range <>) of m_axi_gp_out_t;

-- These definitions currently just match the AXI_HP on zync,
-- the intention is to make them fairly generic at some point
-- Signals are ordered according to the ARM/AXI spec.
-- Outputs from the PS's s_axi_hp ports
constant C_S_AXI_HP_ID_WIDTH   : natural := 6;
constant C_S_AXI_HP_DATA_WIDTH : natural := 64;
constant C_S_AXI_HP_COUNT      : natural := 4;
--type s_axi_hp_out_t is record
--  ARESETn : std_logic; -- in the zynq AXI_HP, the PS as slave drives reset, async
--  AWREADY : std_logic;
--  WREADY  : std_logic;
--  BID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
--  BRESP   : std_logic_vector(1 downto 0);
--  BVALID  : std_logic;
--  ARREADY : std_logic;
--  RID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
--  RDATA   : std_logic_vector(C_S_AXI_HP_DATA_WIDTH-1 downto 0);
--  RRESP   : std_logic_vector(1 downto 0);
--  RLAST   : std_logic;
--  RVALID  : std_logic;
--  -- THese are not AMBA/AXI, but FIFO counts
--  RCOUNT  : std_logic_vector(7 downto 0);
--  WCOUNT  : std_logic_vector(7 downto 0);
--  RACOUNT : std_logic_vector(2 downto 0);
--  WACOUNT : std_logic_vector(5 downto 0);
--end record s_axi_hp_out_t;
-- Inputs to the PS's s_axi_hp ports
--type s_axi_hp_in_t is record
--  ACLK    : std_logic; -- In the zynq AXI_HP, the PL as master supplies the clock
--  AWID    : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
--  AWADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
--  AWLEN   : std_logic_vector(3 downto 0);
--  AWSIZE  : std_logic_vector(2 downto 0); -- bit 2 unused, but in PS7 interface
--  AWBURST : std_logic_vector(1 downto 0);
--  AWLOCK  : std_logic_vector(1 downto 0);
--  AWCACHE : std_logic_vector(3 downto 0);
--  AWPROT  : std_logic_vector(2 downto 0);
--  AWVALID : std_logic;
--  WID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
--  WDATA   : std_logic_vector(C_S_AXI_HP_DATA_WIDTH-1 downto 0);
--  WSTRB   : std_logic_vector((C_S_AXI_HP_DATA_WIDTH/8)-1 downto 0);
--  WLAST   : std_logic;
--  WVALID  : std_logic;
--  BREADY  : std_logic;
--  ARID    : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
--  ARADDR  : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
--  ARLEN   : std_logic_vector(3 downto 0);
--  ARSIZE  : std_logic_vector(2 downto 0); -- bit 2 unused, but in PS7 interface
--  ARBURST : std_logic_vector(1 downto 0);
--  ARLOCK  : std_logic_vector(1 downto 0);
--  ARCACHE : std_logic_vector(3 downto 0);
--  ARPROT  : std_logic_vector(2 downto 0);
--  ARVALID : std_logic;
--  RREADY  : std_logic;
--  -- These are not AMBA/AXI
--  ARQOS   : std_logic_vector(3 downto 0);
--  AWQOS   : std_logic_vector(3 downto 0);
--  RDISSUECAP1_EN : std_logic; -- when true, look at the PS register to throttle
--  WRISSUECAP1_EN : std_logic; -- ditto
--end record s_axi_hp_in_t;

type s_axi_hp_in_aw_t is record
  ID           : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
  ADDR         : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  LEN          : std_logic_vector(3 downto 0);
  SIZE         : std_logic_vector(2 downto 0); -- bit 2 unused, but in PS7 interface
  BURST        : std_logic_vector(1 downto 0);
  LOCK         : std_logic_vector(1 downto 0);
  CACHE        : std_logic_vector(3 downto 0);
  PROT         : std_logic_vector(2 downto 0);
  VALID        : std_logic;
  QOS          : std_logic_vector(3 downto 0);
  ISSUECAP1_EN : std_logic;
end record s_axi_hp_in_aw_t;
type s_axi_hp_out_aw_t is record
  READY : std_logic;
  COUNT : std_logic_vector(5 downto 0);
end record s_axi_hp_out_aw_t;
type s_axi_hp_in_w_t is record
  ID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
  DATA   : std_logic_vector(C_S_AXI_HP_DATA_WIDTH-1 downto 0);
  STRB   : std_logic_vector((C_S_AXI_HP_DATA_WIDTH/8)-1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
end record s_axi_hp_in_w_t;
type s_axi_hp_out_w_t is record
  READY  : std_logic;
  COUNT  : std_logic_vector(7 downto 0);
end record s_axi_hp_out_w_t;
type s_axi_hp_in_ar_t is record
  ID           : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
  ADDR         : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  LEN          : std_logic_vector(3 downto 0);
  SIZE         : std_logic_vector(2 downto 0); -- bit 2 unused, but in PS7 interface
  BURST        : std_logic_vector(1 downto 0);
  LOCK         : std_logic_vector(1 downto 0);
  CACHE        : std_logic_vector(3 downto 0);
  PROT         : std_logic_vector(2 downto 0);
  VALID        : std_logic;
  QOS          : std_logic_vector(3 downto 0);
  ISSUECAP1_EN : std_logic; -- when true, look at the PS register to throttle
end record s_axi_hp_in_ar_t;
type s_axi_hp_out_ar_t is record
  READY : std_logic;
  COUNT : std_logic_vector(2 downto 0);
end record s_axi_hp_out_ar_t;
type s_axi_hp_in_r_t is record
  READY  : std_logic;
end record s_axi_hp_in_r_t;
type s_axi_hp_out_r_t is record
  ID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
  DATA   : std_logic_vector(C_S_AXI_HP_DATA_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
  COUNT  : std_logic_vector(7 downto 0);
end record s_axi_hp_out_r_t;
type s_axi_hp_in_b_t is record
  READY  : std_logic;
end record s_axi_hp_in_b_t;
type s_axi_hp_out_b_t is record
  ID     : std_logic_vector(C_S_AXI_HP_ID_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  VALID  : std_logic;
end record s_axi_hp_out_b_t;
type s_axi_hp_in_t is record
  ACLK    : std_logic; -- In the zynq AXI_HP, the PL as master supplies the clock
  aw : s_axi_hp_in_aw_t;
  ar : s_axi_hp_in_ar_t;
  w  : s_axi_hp_in_w_t;
  r  : s_axi_hp_in_r_t;
  b  : s_axi_hp_in_b_t;
end record s_axi_hp_in_t;
type s_axi_hp_in_array_t is array (natural range <>) of s_axi_hp_in_t;

type s_axi_hp_out_t is record
  ARESETN : std_logic; -- In the zynq AXI_HP, the *PS* as slave supplies the reset
  aw : s_axi_hp_out_aw_t;
  ar : s_axi_hp_out_ar_t;
  w  : s_axi_hp_out_w_t;
  r  : s_axi_hp_out_r_t;
  b  : s_axi_hp_out_b_t;
end record s_axi_hp_out_t;
type s_axi_hp_out_array_t is array (natural range <>) of s_axi_hp_out_t;


-- *****************************
constant C_NO_OF_LANES      : natural := 1;
constant C_S_AXI_ID_WIDTH   : natural := 4;
constant C_S_AXI_ADDR_WIDTH : natural := 32; --zynq is 32
--constant C_S_AXI_DATA_WIDTH : natural := 32;
constant C_S_AXI_DATA_WIDTH : natural := 64; 
constant C_M_AXI_ID_WIDTH   : natural := 4;
constant C_M_AXI_ADDR_WIDTH : natural := 32; --zynq is 32
--constant C_M_AXI_DATA_WIDTH : natural := 32;
constant C_M_AXI_DATA_WIDTH : natural := 64; 

-- *****************************
-- Global Signals
type global_in_t is record
  REFCLK       : std_logic;
  AXI_ARESETN  : std_logic;
--  AXI_ACLK     : std_logic;
--  AXI_CTL_ACLK : std_logic;
end record global_in_t;
type global_out_t is record
  AXI_ACLK_OUT     : std_logic;
  AXI_CTL_ACLK_OUT : std_logic;
  MMCM_LOCK        : std_logic;
  INTERRUPT_OUT    : std_logic;
end record global_out_t;
-- MSI Signals
type msi_in_t is record
  INTX_MSI_Request : std_logic;
  MSI_Vector_Num   : std_logic_vector(4 downto 0);
end record msi_in_t;
type msi_out_t is record
  MSI_enable       : std_logic;
  MSI_Vector_Width : std_logic_vector(2 downto 0);
  INTX_MSI_Grant   : std_logic;
end record msi_out_t;
-- PCIe Interface
type pcie_in_t is record
  PCI_EXP_RXP : std_logic_vector(C_NO_OF_LANES-1 downto 0);
  PCI_EXP_RXN : std_logic_vector(C_NO_OF_LANES-1 downto 0);
end record pcie_in_t;
type pcie_out_t is record
  PCI_EXP_TXP : std_logic_vector(C_NO_OF_LANES-1 downto 0);
  PCI_EXP_TXN : std_logic_vector(C_NO_OF_LANES-1 downto 0);
end record pcie_out_t;


--****************************--
-- AXI4-Lite Control Interface
type s_axi_lite_in_aw_t is record
  ADDR  : std_logic_vector(31 downto 0);
  VALID : std_logic;
end record s_axi_lite_in_aw_t;
type s_axi_lite_out_aw_t is record
  READY : std_logic;
end record s_axi_lite_out_aw_t;
type s_axi_lite_in_w_t is record
  DATA  : std_logic_vector(31 downto 0);
  STRB  : std_logic_vector(3 downto 0);
  VALID : std_logic;
end record s_axi_lite_in_w_t;
type s_axi_lite_out_w_t is record
  READY : std_logic;
end record s_axi_lite_out_w_t;
type s_axi_lite_in_b_t is record
  READY : std_logic;
end record s_axi_lite_in_b_t;
type s_axi_lite_out_b_t is record
  VALID : std_logic;
  RESP  : std_logic_vector(1 downto 0);
end record s_axi_lite_out_b_t;
type s_axi_lite_in_ar_t is record
  ADDR  : std_logic_vector(31 downto 0);
  VALID : std_logic;
end record s_axi_lite_in_ar_t;
type s_axi_lite_out_ar_t is record
  READY : std_logic;
end record s_axi_lite_out_ar_t;
type s_axi_lite_in_r_t is record
  READY : std_logic;
end record s_axi_lite_in_r_t;
type s_axi_lite_out_r_t is record
  DATA  : std_logic_vector(31 downto 0);
  RESP  : std_logic_vector(1 downto 0);
  VALID : std_logic;
end record s_axi_lite_out_r_t;
--****************************--


--****************************--
-- AXI Slave Interface (OpenCPI Data Plane)
-- Provides termination of MM AXI4 transactions from an AXI master device
type s_axi_in_aw_t is record
  ID           : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
  ADDR         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  REGION       : std_logic_vector(3 downto 0);  
  LEN          : std_logic_vector(7 downto 0);
  SIZE         : std_logic_vector(2 downto 0);
  BURST        : std_logic_vector(1 downto 0);
  LOCK         : std_logic_vector(1 downto 0);
  CACHE        : std_logic_vector(3 downto 0);
  PROT         : std_logic_vector(2 downto 0);
  VALID        : std_logic;
  QOS          : std_logic_vector(3 downto 0);
  ISSUECAP1_EN : std_logic;
end record s_axi_in_aw_t;
type s_axi_out_aw_t is record
  READY : std_logic;
end record s_axi_out_aw_t;
type s_axi_in_w_t is record
  ID     : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0); -- not used by SDP
  DATA   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  STRB   : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
end record s_axi_in_w_t;
type s_axi_out_w_t is record
  READY  : std_logic;
end record s_axi_out_w_t;
type s_axi_in_b_t is record
  READY  : std_logic;
end record s_axi_in_b_t;
type s_axi_out_b_t is record
  ID     : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  VALID  : std_logic;
end record s_axi_out_b_t;
type s_axi_in_ar_t is record
  ID           : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
  ADDR         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  REGION       : std_logic_vector(3 downto 0);
  LEN          : std_logic_vector(7 downto 0);
  SIZE         : std_logic_vector(2 downto 0);
  BURST        : std_logic_vector(1 downto 0);
  LOCK         : std_logic_vector(1 downto 0);
  CACHE        : std_logic_vector(3 downto 0);
  PROT         : std_logic_vector(2 downto 0);
  VALID        : std_logic;
  QOS          : std_logic_vector(3 downto 0);
  ISSUECAP1_EN : std_logic;
end record s_axi_in_ar_t;
type s_axi_out_ar_t is record
  READY : std_logic;
end record s_axi_out_ar_t;
type s_axi_in_r_t is record
  READY  : std_logic;
end record s_axi_in_r_t;
type s_axi_out_r_t is record
  ID     : std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
  DATA   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
end record s_axi_out_r_t;
--****************************--
type s_axi_in_t is record
  ACLK    : std_logic; -- Required for OpenCPI. The PL as master supplies the clock
  aw : s_axi_in_aw_t;
  ar : s_axi_in_ar_t;
  w  : s_axi_in_w_t;
  r  : s_axi_in_r_t;
  b  : s_axi_in_b_t;
end record s_axi_in_t;
type s_axi_in_array_t is array (natural range <>) of s_axi_in_t;
--
type s_axi_out_t is record
--  ARESETN : std_logic; -- In the zynq AXI_HP, the *PS* as slave supplies the reset
  aw : s_axi_out_aw_t;
  ar : s_axi_out_ar_t;
  w  : s_axi_out_w_t;
  r  : s_axi_out_r_t;
  b  : s_axi_out_b_t;
end record s_axi_out_t;
type s_axi_out_array_t is array (natural range <>) of s_axi_out_t;
--****************************--

--****************************--
-- AXI Master Interface (OpenCPI Control Plane)
-- Processes both PCIe MemWr and MemRd request TLPs received from the integrated
-- block for PCI Express and provides a means to translate addresses that are mapped
-- within the address for PCIe domain to the MM AXI4 address domain
type m_axi_in_aw_t is record
  READY : std_logic;
end record m_axi_in_aw_t;
type m_axi_out_aw_t is record
  ADDR         : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
  LEN          : std_logic_vector(7 downto 0);
  SIZE         : std_logic_vector(2 downto 0);
  BURST        : std_logic_vector(1 downto 0);
  PROT         : std_logic_vector(2 downto 0);
  VALID        : std_logic;
  CACHE        : std_logic_vector(3 downto 0); -- not listed in pg055-axi-bridge-pcie_v1.06.a.pdf
  LOCK         : std_logic;                    -- not listed in pg055-axi-bridge-pcie_v1.06.a.pdf
end record m_axi_out_aw_t;
type m_axi_in_w_t is record
  READY  : std_logic;
end record m_axi_in_w_t;
type m_axi_out_w_t is record
  DATA   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
  STRB   : std_logic_vector((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
end record m_axi_out_w_t;
type m_axi_in_b_t is record
  ID     : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  VALID  : std_logic;
end record m_axi_in_b_t;
type m_axi_out_b_t is record
  READY  : std_logic;
end record m_axi_out_b_t;
type m_axi_in_ar_t is record
  READY : std_logic;
end record m_axi_in_ar_t;
type m_axi_out_ar_t is record
  ADDR         : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
  LEN          : std_logic_vector(7 downto 0);
  SIZE         : std_logic_vector(2 downto 0);
  BURST        : std_logic_vector(1 downto 0);
  PROT         : std_logic_vector(2 downto 0);  
  VALID        : std_logic;
  CACHE        : std_logic_vector(3 downto 0); -- not listed in pg055-axi-bridge-pcie_v1.06.a.pdf
  LOCK         : std_logic;                    -- not listed in pg055-axi-bridge-pcie_v1.06.a.pdf
end record m_axi_out_ar_t;
type m_axi_in_r_t is record
  ID     : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
  DATA   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
  RESP   : std_logic_vector(1 downto 0);
  LAST   : std_logic;
  VALID  : std_logic;
end record m_axi_in_r_t;
type m_axi_out_r_t is record
  READY  : std_logic;
end record m_axi_out_r_t;
--****************************--
type m_axi_in_t is record
  ACLK    : std_logic; -- Required? for OpenCPI. The PL as master supplies the clock
  aw : m_axi_in_aw_t;
  ar : m_axi_in_ar_t;
  w  : m_axi_in_w_t;
  r  : m_axi_in_r_t;
  b  : m_axi_in_b_t;
end record m_axi_in_t;
type m_axi_in_array_t is array (natural range <>) of m_axi_in_t;
--
type m_axi_out_t is record
--  ARESETN : std_logic; -- In the zynq AXI_HP, the *PS* as slave supplies the reset
  aw : m_axi_out_aw_t;
  ar : m_axi_out_ar_t;
  w  : m_axi_out_w_t;
  r  : m_axi_out_r_t;
  b  : m_axi_out_b_t;
end record m_axi_out_t;
type m_axi_out_array_t is array (natural range <>) of m_axi_out_t;
--****************************--


subtype  Resp_t IS std_logic_vector(1 downto 0);
constant Resp_OKAY   : Resp_t := "00";
constant Resp_EXOKAY : Resp_t := "01";
constant Resp_SLVERR : Resp_t := "10";
constant Resp_DECERR : Resp_t := "11";

component axi2cp is
  port(
    clk     : in std_logic;
    reset   : in bool_t;
    axi_in  : in  m_axi_out_t;
    axi_out : out m_axi_in_t;
    cp_in   : in  occp_out_t;
    cp_out  : out occp_in_t
    );
end component axi2cp;

component unoc2axi is
  generic(
    ocpi_debug : boolean
    );
  port(
    clk       : in  std_logic;
    reset     : in  bool_t;
    unoc_in   : in  unoc_master_in_t;
    unoc_out  : out unoc_master_out_t;
    axi_in    : in  s_axi_out_t;
    axi_out   : out s_axi_in_t;
    axi_error : out bool_t;
    dbg_state : out ulonglong_t;
    dbg_state1 : out ulonglong_t;
    dbg_state2 : out ulonglong_t
    );
end component unoc2axi;

component axinull is
  port(
    clk       : in  std_logic;
    reset     : in  bool_t;
    axi_in    : in  s_axi_out_t;
    axi_out   : out s_axi_in_t
    );
end component axinull;

end package axi_pkg;
