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

-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE WORK.FORKSKINNYPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY SBox_dec IS
	GENERIC (BS : BLOCK_SIZE);
	PORT ( X : IN	STD_LOGIC_VECTOR ((GET_WORD_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR ((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END SBox_dec;



-- ARCHITECTURE : WORD
----------------------------------------------------------------------------------
ARCHITECTURE Word OF SBox_dec IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL NO7, XO7, NO6, XO6, NO5, XO5, NO4, XO4, NO3, XO3, NO2, XO2, NO1, XO1, NO0, XO0 : STD_LOGIC;
	SIGNAL O, P												 : STD_LOGIC_VECTOR(39 DOWNTO 0);

BEGIN

	-- 4-BIT S-BOX ----------------------------------------------------------------
	S4 : IF BS = BLOCK_SIZE_64 GENERATE
		NO3 <= X(3) NOR X(2);
		XO3 <= X(0) XOR NO3;

		NO2 <= X(3) NOR XO3;
		XO2 <= X(1) XOR NO2;

		NO1 <= XO3  NOR XO2;
		XO1 <= X(2) XOR NO1;

		NO0 <= XO1 NOR XO2;
		XO0 <= X(3) XOR NO0;

		Y <= XO1 & XO2 & XO3 & XO0;
	END GENERATE;
	-------------------------------------------------------------------------------

	-- 8-BIT S-BOX ----------------------------------------------------------------
	S8 : IF BS = BLOCK_SIZE_128 GENERATE

    NO6 <= X(7) nor X(6);
    XO6 <= NO6 xor X(4);
    NO7 <= X(3) nor x(1);
    XO7 <= X(0) xor NO7;
    NO4 <= X(5) nor XO6;
    XO4 <= NO4 xor X(3);
    NO5 <= X(2) nor X(7);
    XO5 <= X(1) xor NO5;
    NO2 <= XO7 nor XO4;
    XO2 <= NO2 xor X(2);
    NO3 <= X(6) nor X(5);
    XO3 <= X(7) xor NO3;
    NO0 <= XO2 nor XO5;
    XO0 <= NO0 xor X(6);
    NO1 <= XO6 nor XO7;
    XO1 <= X(5) xor NO1;

    Y <= XO5 & XO2 & XO3 & XO0 & XO6 & XO7 & XO4 & XO1;

	END GENERATE;
	-------------------------------------------------------------------------------

END Word;
