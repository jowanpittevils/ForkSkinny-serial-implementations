----------------------------------------------------------------------------------
-- Copyright 2019-2020:
--     Jowan Pittevils for the FORKAE Team
--     https://www.esat.kuleuven.be/cosic/forkae/
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE WORK.ForkSkinnyPKG.ALL;

ENTITY fork_reg IS
  generic (BS: BLOCK_SIZE);
	PORT ( clk: IN STD_LOGIC;
		D: IN STD_LOGIC_vector((GET_BLOCK_SIZE(BS)/16 	   - 1) DOWNTO 0);
    enable: IN STD_LOGIC;
		Q: INOUT STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS) 	   - 1) DOWNTO 0));

end fork_reg;

ARCHITECTURE structural OF fork_reg IS

BEGIN


reg16 : entity work.DATAFF_enable generic map(SIZE => (GET_BLOCK_SIZE(BS)/16)) PORT MAP(CLK,enable,D,Q(1*(GET_BLOCK_SIZE(BS)/16)-1 downto 0*(GET_BLOCK_SIZE(BS)/16)));

gen_reg : FOR i in 1 to 15 generate
  regi : entity work.DataFF_enable generic map(SIZE => (GET_BLOCK_SIZE(BS)/16)) PORT MAP(CLK,enable,Q(((I)*(GET_BLOCK_SIZE(BS)/16)-1) downto (i-1)*(GET_BLOCK_SIZE(BS)/16)),Q((I+1)*(GET_BLOCK_SIZE(BS)/16)-1 downto (i)*(GET_BLOCK_SIZE(BS)/16)));
end generate;


END structural;
