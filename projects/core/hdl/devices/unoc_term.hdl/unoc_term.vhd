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

-- THIS FILE WAS ORIGINALLY GENERATED ON Mon Oct 24 08:44:59 2016 EDT
-- BASED ON THE FILE: unoc_term.xml
-- YOU *ARE* EXPECTED TO EDIT IT
-- This file initially contains the architecture skeleton for worker: unoc_term
-- Note THIS IS THE OUTER skeleton, since the 'outer' attribute was set.

library IEEE; use IEEE.std_logic_1164.all; use ieee.numeric_std.all;
library ocpi; use ocpi.types.all; -- remove this to avoid all ocpi name collisions
library platform; use platform.platform_pkg.all;
architecture rtl of unoc_term_rv is
  signal count_r : unsigned(up_out.dropCount'range);
begin
  up_out.data      <= to_unoc(util.slv0(unoc_data_width));
  up_out.valid     <= '0';
  up_out.take      <= up_in.valid;
  up_out.dropCount <= count_r;

  process (up_in.clk) is
  begin
    if rising_edge(up_in.clk) then
      if up_in.reset_n = '0' then
        count_r <= (others => '0');
      elsif up_in.valid = '1' and count_r /= 255 then
        count_r <= count_r + 1;
      end if;
    end if;
  end process;
end rtl;
