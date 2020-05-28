----------------------------------------------------------------------------------
-- Copyright 2016-2019:
--     Amir Moradi & Pascal Sasdrich for the SKINNY Team
--     https://sites.google.com/site/skinnycipher/
--
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



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY DataFF IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END DataFF;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF DataFF IS

BEGIN

	-------------------------------------------------------------------------------
	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			Q	<= D;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------

END Behavioral;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY DataFF_enable IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
					enable : in std_logic;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END DataFF_enable;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF DataFF_enable IS

BEGIN

	-------------------------------------------------------------------------------
	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			if(enable = '1') then
				Q	<= D;
		end if;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------

END Behavioral;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY DataFF_reset IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
					reset : IN STD_LOGIC;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END DataFF_reset;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF DataFF_reset IS

BEGIN

	-------------------------------------------------------------------------------
	PROCESS(CLK,reset) BEGIN
		if (reset = '1') THEN
			Q <= (others => '0');
		elsIF RISING_EDGE(CLK) THEN
				Q	<= D;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------

END Behavioral;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY DataFF_reset_enable IS
	GENERIC (SIZE : INTEGER);
	PORT ( CLK	: IN 	STD_LOGIC;
				enable : in std_logic;
					reset : IN STD_LOGIC;
          D  	: IN 	STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END DataFF_reset_enable;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF DataFF_reset_enable IS

BEGIN

	-------------------------------------------------------------------------------
	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			if (reset = '1') THEN
				Q <= (others => '0');
	  	elsif(enable = '1') then
				Q	<= D;
			end if;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------

END Behavioral;
