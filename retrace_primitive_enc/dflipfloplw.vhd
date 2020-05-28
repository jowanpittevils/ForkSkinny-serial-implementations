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


ENTITY dflipfloplw IS
	PORT ( clk: IN STD_LOGIC;
		sel: IN STD_LOGIC;
		D0: IN STD_LOGIC;
		D1: IN STD_LOGIC;
		Q: OUT STD_LOGIC);

end dflipfloplw;

ARCHITECTURE test OF dflipfloplw IS
signal Signal1 : std_logic := '0';

BEGIN
	Signal1 <= sel;
	PROCESS(clk) BEGIN
		IF RISING_EDGE(clk) THEN
			if (Signal1 = '1') THEN
				Q <= D1;
			else
				Q <= D0;
			END IF;
		END IF;
	END PROCESS;
END test;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY dflipfloplw_reset IS
	PORT ( clk: IN STD_LOGIC;
	reset : IN STD_LOGIC;
		sel: IN STD_LOGIC;
		D0: IN STD_LOGIC;
		D1: IN STD_LOGIC;
		Q: OUT STD_LOGIC);

end dflipfloplw_reset;

ARCHITECTURE test OF dflipfloplw_reset IS
signal Signal1 : std_logic := '0';

BEGIN
	Signal1 <= sel;
	PROCESS(clk) BEGIN
		IF RISING_EDGE(clk) THEN
			if (reset = '1') THEN
				Q <= '0';
			elsif (Signal1 = '1') THEN
				Q <= D1;
			else
				Q <= D0;
			END IF;
		END IF;
	END PROCESS;
END test;
