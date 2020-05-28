----------------------------------------------------------------------------------
-- Copyright 2020 (for decryption and forkcipher):
--     Jowan Pittevils for the ForkAE team
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

entity Fork_reg is
  generic(BS : BLOCK_SIZE);
  PORT(CLK : in std_logic;
        enable : in std_logic;
        word_in : in STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)/16)-1 downto 0);
        Q_out : out STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS))-1 downto 0));
end Fork_reg;

ARCHITECTURE structural of Fork_reg is

signal Q : STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS))-1 downto 0);
signal MSB_Q : STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)/16)-1 downto 0);

  BEGIN
Q_out <= Q;
MSB_Q <= Q(16*(GET_BLOCK_SIZE(BS)/16)-1 downto 15*(GET_BLOCK_SIZE(BS)/16));



  reg16 : entity work.DataFF_enable generic map(SIZE => (GET_BLOCK_SIZE(BS)/16)) PORT MAP(CLK,enable,word_in,Q(1*(GET_BLOCK_SIZE(BS)/16)-1 downto 0*(GET_BLOCK_SIZE(BS)/16)));

  gen_reg : FOR i in 1 to 15 generate
    regi : entity work.DataFF_enable generic map(SIZE => (GET_BLOCK_SIZE(BS)/16)) PORT MAP(CLK,enable,Q(((I)*(GET_BLOCK_SIZE(BS)/16)-1) downto (i-1)*(GET_BLOCK_SIZE(BS)/16)),Q((I+1)*(GET_BLOCK_SIZE(BS)/16)-1 downto (i)*(GET_BLOCK_SIZE(BS)/16)));
  end generate;

end structural;
