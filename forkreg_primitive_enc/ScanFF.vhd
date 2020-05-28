----------------------------------------------------------------------------------
-- Copyright 2016-2019:
--     Amir Moradi & Pascal Sasdrich for the SKINNY Team
--     https://sites.google.com/site/skinnycipher/
--
-- Copyright 2019-2020 (for modifications):
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




-- IMPORTS
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY ScanFF IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
          SE 	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          DS	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END ScanFF;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF ScanFF IS

signal temp : STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);

-------------------------------------------------------------------------------

BEGIN

process(SE,D,DS) begin
	if (SE = '1') then
		temp <= DS;
	else
		temp <= D;
	end if;
end process;

process(clk) BEGIN
	if(RISING_EDGE(clk)) then
			Q <= temp;
	end if;
end process;
END Structural;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY ScanFF_enable IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
          SE 	: IN 	STD_LOGIC;
					enable : in std_logic;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          DS	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END ScanFF_enable;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF ScanFF_enable IS

	-- COMPONENTS -----------------------------------------------------------------
	signal temp : STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);

	-------------------------------------------------------------------------------

BEGIN

	process(SE,D,DS) begin
		if (SE = '1') then
			temp <= DS;
		else
			temp <= D;
		end if;
	end process;
	process(clk) BEGIN
		if(RISING_EDGE(clk)) then
			if(enable = '1') THEN
				Q <= temp;
			end if;
		end if;
	end process;
END Structural;
