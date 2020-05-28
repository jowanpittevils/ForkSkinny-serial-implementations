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
          DONE       : INOUT STD_LOGIC;
   	    -- KEY PORT -------------------------------------
          KEY        : IN STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*GET_WORD_SIZE(BS)) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          PLAINTEXT  : IN  STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) 	 / 16) - 1) DOWNTO 0);
          CIPHERTEXT : INOUT STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) ) - 1) DOWNTO 0));
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
	SIGNAL Branch_cst :  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS)/16)	   - 1) DOWNTO 0);
	signal BRANCH_cst_enable : std_logic;
	signal retracing : std_logic;
	signal state_msb : STD_LOGIC_VECTOR(((N / 16) - 1) DOWNTO 0);
	signal Fork_state : STD_LOGIC_VECTOR(((N ) - 1) DOWNTO 0);
	signal fork_reg_enable  : std_logic;
	signal FORK_REACHED : std_logic;
	signal FORK_STATE_MSB,RF_INPUT : STD_LOGIC_VECTOR(((N / 16) - 1) DOWNTO 0);
	signal rf_reset : std_logic;
BEGIN
RF_enable <= '1';

fork_reg_enable <= FORK_REACHED;

state_msb <= CIPHERTEXT(N-1 downto 15*N/16);

FORK_state_msb <= FORK_STATE(N-1 downto 15*N/16);

rf_reset <= reset or done;

RF_INPUT <= PLAINTEXT when reset = '1' else FORK_STATE_MSB;

Fork_reg : entity work.fork_reg GENERIC MAP (BS => BS) PORT MAP (CLK,fork_reg_enable,state_msb,Fork_state);

	BC : entity work.lfsr_counter GENERIC MAP (BS => BS) PORT MAP (CLK,BRANCH_cst_enable, Branch_cst);
	-- ROUND FUNCTION -------------------------------------------------------------
	RF : ENTITY work.RoundFunction GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, rf_reset, RF_enable, ROUND_CTL, ROUND_CST, Branch_cst, ROUND_KEY, RF_INPUT, CIPHERTEXT);
	-------------------------------------------------------------------------------

   -- KEY EXPANSION --------------------------------------------------------------
   KE : ENTITY work.KeyExpansion  GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, KEY_CTL,done, KEY, ROUND_KEY);
	-------------------------------------------------------------------------------

   -- CONTROL LOGIC --------------------------------------------------------------
   CL : ENTITY work.ControlLogic GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET,DONE, ROUND_CTL, KEY_CTL,FORK_REACHED, ROUND_CST,branch_cst_enable);
	-------------------------------------------------------------------------------

END Structural;
