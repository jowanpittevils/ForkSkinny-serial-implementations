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
signal Signal1 : std_logic;
signal temp : std_logic;

BEGIN
	Signal1 <= sel;
	PROCESS(clk) BEGIN
		IF RISING_EDGE(clk) THEN
			if (Signal1 = '1') THEN
				temp <= D1;
			else
				temp <= D0;
			END IF;
		END IF;
	END PROCESS;
	Q<=temp;
END test;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY dflipfloplw_enable IS
	PORT ( clk: IN STD_LOGIC;
		sel: IN STD_LOGIC;
		enable : in std_logic;
		D0: IN STD_LOGIC;
		D1: IN STD_LOGIC;
		Q: OUT STD_LOGIC);

end dflipfloplw_enable;

ARCHITECTURE test OF dflipfloplw_enable IS
signal Signal1 : std_logic;
signal Q_in : std_logic;

BEGIN
	Q <= Q_in;
	Signal1 <= sel;
	PROCESS(clk) BEGIN
		IF RISING_EDGE(clk) THEN
			if(enable = '1') then
				if (Signal1 = '1') THEN
					Q_in <= D1;
				else
					Q_in <= D0;
				END IF;
			end if;
		END IF;
	END PROCESS;
END test;
