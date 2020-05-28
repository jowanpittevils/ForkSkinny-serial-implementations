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

USE WORK.ForkSkinnyPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY ForkSkinny IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAKEY_SIZE 		 := TWEAKEY_SIZE_192);
   PORT ( CLK        : IN  STD_LOGIC;
   		 -- CONTROL PORTS --------------------------------
          RESET      : IN  STD_LOGIC;
					decrypt: in STD_LOGIC;
          DONE       : INOUT STD_LOGIC;
   	    -- KEY PORT -------------------------------------
          KEY        : IN STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*GET_WORD_SIZE(BS)) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          PLAINTEXT  : IN  STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) 	 / 16) - 1) DOWNTO 0);
          CIPHERTEXT : OUT STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) ) - 1) DOWNTO 0));
END ForkSkinny;



-- ARCHITECTURE : Structural
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF ForkSkinny IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAKEY_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
   SIGNAL ROUND_CTL : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL KEY_CTL   : STD_LOGIC_VECTOR(1 DOWNTO 0);

	signal ROUND_KEY		:	STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*get_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
	SIGNAL ROUND_CST : STD_LOGIC_VECTOR(((N / 16) - 1) DOWNTO 0);

	signal RF_enable : std_logic;
	signal updating_key : std_logic;
	signal key_reverse : std_logic;
	signal RF_reverse : std_logic;
	SIGNAL Branch_cst :  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS)/16)	   - 1) DOWNTO 0);
	signal BRANCH_cst_enable : std_logic;
	signal retracing : std_logic;
BEGIN
key_reverse <=  retracing;
RF_reverse <= retracing;
RF_enable <= (not (updating_key)) or reset;
	BC : entity work.lfsr_counter GENERIC MAP (BS => BS) PORT MAP (CLK,BRANCH_cst_enable, Branch_cst);
	-- ROUND FUNCTION -------------------------------------------------------------
	RF : ENTITY work.RoundFunction GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET,RF_reverse, RF_enable, ROUND_CTL, ROUND_CST, Branch_cst, ROUND_KEY, PLAINTEXT, CIPHERTEXT);
	-------------------------------------------------------------------------------

   -- KEY EXPANSION --------------------------------------------------------------
   KE : ENTITY work.KeyExpansion  GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, key_reverse, KEY_CTL,done, KEY, ROUND_KEY);
	-------------------------------------------------------------------------------

   -- CONTROL LOGIC --------------------------------------------------------------
   CL : ENTITY work.ControlLogic GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, DECRYPT,DONE, ROUND_CTL, KEY_CTL, ROUND_CST,retracing,branch_cst_enable,updating_key);
	-------------------------------------------------------------------------------

END Structural;
