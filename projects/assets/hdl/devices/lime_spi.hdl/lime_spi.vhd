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

-- THIS FILE WAS ORIGINALLY GENERATED ON Tue Aug 12 17:24:09 2014 EDT
-- BASED ON THE FILE: lime_spi.xml
-- YOU *ARE* EXPECTED TO EDIT IT
-- This file initially contains the architecture skeleton for worker: lime_spi

library IEEE, ocpi, util;
use IEEE.std_logic_1164.all, ieee.numeric_std.all;
use ocpi.all, ocpi.types.all, ocpi.util.all;
architecture rtl of lime_spi_worker is
  constant rx_c         : natural := 0;         
  constant tx_c         : natural := 1;         
  constant addr_width_c : natural := 7;
  -- Internal signals
  signal rdata      : std_logic_vector(7 downto 0);
  signal wdata      : std_logic_vector(7 downto 0);
  signal addr       : unsigned(addr_width_c-1 downto 0);
  -- Convenience
  signal lsb        : natural range 0 to 31;
  signal raw_in     : wci.raw_prop_out_t;
  signal raw_out    : wci.raw_prop_in_t;
begin
  -- Assert chip reset if system is reset or both clients are reset, chip reset as asserted low
  RESET        <= not (raw_in.reset);
  lsb          <= 8 * to_integer(raw_in.raw.address(1 downto 0));
  -- These are temp signals because Xilinx isim can't put them as actuals
  wdata        <= raw_in.raw.data(lsb + 7 downto lsb);
  addr         <= raw_in.raw.address(addr'range);
  raw_out.raw.data  <= rdata & rdata & rdata & rdata;
  -- Use the generic raw property arbiter between rx and tx
  arb : wci.raw_arb
    generic map(nusers => 2)
    port map(
      clk         => wci_clk,
      reset       => wci_reset,
      from_users  => rprops_in,
      to_users    => rprops_out,
      from_device => raw_out,
      to_device   => raw_in);
  -- Drive SPI from the arbitrated raw interface
  spi : util.util.spi
    generic map(
      data_width    => 8,
      addr_width    => addr_width_c,
      clock_divisor => to_integer(to_unsigned(from_float(CLK_FREQ_p)/3125000,16)) -- SPI clk = ~ 3.125MHz
      )
    port map(
      clk     => wci_clk,
      reset   => wci_reset,
      renable => raw_in.raw.is_read,
      wenable => raw_in.raw.is_write,
      addr    => addr,
      wdata   => wdata,
      rdata   => rdata,
      done    => raw_out.raw.done,
      sdo     => sdo,
      sclk    => sclk,
      sen     => sen,
      sdio    => sdio
      );
end rtl;
