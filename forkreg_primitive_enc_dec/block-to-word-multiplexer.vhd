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

USE WORK.FORKSKINNYPKG.ALL;

entity word_mux is
  generic(BS : BLOCK_SIZE; TS: TWEAKEY_SIZE);
  port(
    CLK : in std_logic;
    PLAINTEXT  : IN  STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) ) - 1) DOWNTO 0);
    plaintext_word : out STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
    COUNTER_temp			: in  INTEGER RANGE 0 TO 20);
  end word_mux;

ARCHITECTURE Structural OF word_mux IS
begin
process(COUNTER_temp,plaintext) is
  begin
  case COUNTER_temp is
    when 0 => PLAINTEXT_word <= PLAINTEXT((16-0)*GET_BLOCK_SIZE(BS)/16-1 downto (15-0)*GET_BLOCK_SIZE(BS)/16);
    when 1 => PLAINTEXT_word <= PLAINTEXT((16-1)*GET_BLOCK_SIZE(BS)/16-1 downto (15-1)*GET_BLOCK_SIZE(BS)/16);
    when 2 => PLAINTEXT_word <= PLAINTEXT((16-2)*GET_BLOCK_SIZE(BS)/16-1 downto (15-2)*GET_BLOCK_SIZE(BS)/16);
    when 3 => PLAINTEXT_word <= PLAINTEXT((16-3)*GET_BLOCK_SIZE(BS)/16-1 downto (15-3)*GET_BLOCK_SIZE(BS)/16);
    when 4 => PLAINTEXT_word <= PLAINTEXT((16-4)*GET_BLOCK_SIZE(BS)/16-1 downto (15-4)*GET_BLOCK_SIZE(BS)/16);
    when 5 => PLAINTEXT_word <= PLAINTEXT((16-5)*GET_BLOCK_SIZE(BS)/16-1 downto (15-5)*GET_BLOCK_SIZE(BS)/16);
    when 6 => PLAINTEXT_word <= PLAINTEXT((16-6)*GET_BLOCK_SIZE(BS)/16-1 downto (15-6)*GET_BLOCK_SIZE(BS)/16);
    when 7 => PLAINTEXT_word <= PLAINTEXT((16-7)*GET_BLOCK_SIZE(BS)/16-1 downto (15-7)*GET_BLOCK_SIZE(BS)/16);
    when 8 => PLAINTEXT_word <= PLAINTEXT((16-8)*GET_BLOCK_SIZE(BS)/16-1 downto (15-8)*GET_BLOCK_SIZE(BS)/16);
    when 9 => PLAINTEXT_word <= PLAINTEXT((16-9)*GET_BLOCK_SIZE(BS)/16-1 downto (15-9)*GET_BLOCK_SIZE(BS)/16);
    when 10 => PLAINTEXT_word <= PLAINTEXT((16-10)*GET_BLOCK_SIZE(BS)/16-1 downto (15-10)*GET_BLOCK_SIZE(BS)/16);
    when 11 => PLAINTEXT_word <= PLAINTEXT((16-11)*GET_BLOCK_SIZE(BS)/16-1 downto (15-11)*GET_BLOCK_SIZE(BS)/16);
    when 12 => PLAINTEXT_word <= PLAINTEXT((16-12)*GET_BLOCK_SIZE(BS)/16-1 downto (15-12)*GET_BLOCK_SIZE(BS)/16);
    when 13 => PLAINTEXT_word <= PLAINTEXT((16-13)*GET_BLOCK_SIZE(BS)/16-1 downto (15-13)*GET_BLOCK_SIZE(BS)/16);
    when 14 => PLAINTEXT_word <= PLAINTEXT((16-14)*GET_BLOCK_SIZE(BS)/16-1 downto (15-14)*GET_BLOCK_SIZE(BS)/16);
    when 15 => PLAINTEXT_word <= PLAINTEXT((16-15)*GET_BLOCK_SIZE(BS)/16-1 downto (15-15)*GET_BLOCK_SIZE(BS)/16);
    when others => PLAINTEXT_word <= PLAINTEXT((16-0)*GET_BLOCK_SIZE(BS)/16-1 downto (15-0)*GET_BLOCK_SIZE(BS)/16);
  end case;
end process;

END Structural;
