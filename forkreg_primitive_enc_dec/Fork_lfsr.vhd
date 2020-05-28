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
use ieee.numeric_std.all;

USE WORK.ForkSkinnyPKG.ALL;

entity lfsr_counter is
   generic (BS: BLOCK_SIZE);
   port( CLK: in std_logic;
 	       BRANCH_cst_enable: in std_logic;
        Branch_constant: OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS)/16)	   - 1) DOWNTO 0));
end lfsr_counter;

architecture Behavioral of lfsr_counter is
   signal temp: unsigned(3 downto 0);
   Signal Branch_constant_temp : STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS)/16)	   - 1) DOWNTO 0);
begin

   BRANCH_constant <= Branch_constant_temp;

   N64 : IF BS = BLOCK_SIZE_64 GENERATE
     PROCESS(CLK) BEGIN
      if(RISING_EDGE(CLK)) then
         IF ((Branch_constant_temp = "0000") and (BRANCH_cst_enable = '1')) THEN
             Branch_constant_temp <= ("0001");
         elsif (BRANCH_cst_enable = '1') THEN
             Branch_constant_temp <= Branch_constant_temp(((GET_BLOCK_SIZE(BS)/16)-2) DOWNTO 0) & (Branch_constant_temp((GET_BLOCK_SIZE(BS)/16)-1) XOR Branch_constant_temp((GET_BLOCK_SIZE(BS)/16)-2));
         else
           Branch_constant_temp <= "0000";
         END IF;
       end if;
     END PROCESS;
   end GENERATE;

   N128 : IF BS = BLOCK_SIZE_128 GENERATE
   PROCESS(CLK) BEGIN
      if(RISING_EDGE(CLK)) then
         IF ((Branch_constant_temp = "00000000") and (BRANCH_cst_enable = '1')) THEN
             Branch_constant_temp <= ("00000001");
         elsif (BRANCH_cst_enable = '1') THEN
             Branch_constant_temp <= Branch_constant_temp(((GET_BLOCK_SIZE(BS)/16)-2) DOWNTO 0) & (Branch_constant_temp((GET_BLOCK_SIZE(BS)/16)-1) XOR Branch_constant_temp((GET_BLOCK_SIZE(BS)/16)-3));
         else
           Branch_constant_temp <= "00000000";
         END IF;
       END IF;
     END PROCESS;
   end GENERATE;
end Behavioral;
