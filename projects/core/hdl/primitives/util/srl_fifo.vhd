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

library IEEE, ocpi;
use IEEE.std_logic_1164.all, ieee.numeric_std.all, ocpi.types.all, ocpi.util.all;
entity srl_fifo is
  generic(width    : positive;
          depth    : positive := 16);
  port   (clk      : in  std_logic;
          reset    : in  bool_t;
          clear    : in  bool_t := bfalse;
          enq      : in  bool_t;
          deq      : in  bool_t;
          input    : in  std_logic_vector(width-1 downto 0);
          full     : out bool_t;
          empty    : out bool_t;
          output   : out std_logic_vector(width-1 downto 0));
end srl_fifo;
architecture rtl of srl_fifo is
  signal rst_n   : std_logic;
  signal full_n  : std_logic;
  signal empty_n : std_logic;
  -- this is an internal declaration, not in this library's package declaration
  -- it is only necessary because Quartus refuses to instantiate a verilog entity
  -- already seen in the same compilation. grrrr.
  component arSRLFIFOD
    generic(width   : natural;
            l2depth : natural);
    port   (CLK     : in  std_logic;
            RST_N   : in  std_logic;
            CLR     : in  std_logic;
            ENQ     : in  std_logic;
            DEQ     : in  std_logic;
            FULL_N  : out std_logic;
            EMPTY_N : out std_logic;
            D_IN    : in  std_logic_vector(width-1 downto 0);
            D_OUT   : out std_logic_vector(width-1 downto 0));
    end component arSRLFIFOD;
begin
  rst_n <= not reset;
  full  <= not full_n;
  empty <= not empty_n;
  arsrl : component arSRLFIFOD
    generic map(width => width,
                l2depth => width_for_max(depth-1))
    port map   (CLK     => clk,
                RST_N   => rst_n,
                CLR     => clear,
                ENQ     => enq,
                DEQ     => deq,
                FULL_N  => full_n,
                EMPTY_N => empty_n,
                D_IN    => input,
                D_OUT   => output);
end rtl;
