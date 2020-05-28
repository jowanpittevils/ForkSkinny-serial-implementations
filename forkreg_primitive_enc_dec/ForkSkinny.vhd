----------------------------------------------------------------------------------
-- Copyright 2016-2019:
--     Amir Moradi & Pascal Sasdrich for the SKINNY Team
--     https://sites.google.com/site/skinnycipher/
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
	GENERIC ( BS : BLOCK_SIZE := BLOCK_SIZE_64;
				 TS : TWEAKEY_SIZE := TWEAKEY_SIZE_192);
   PORT ( CLK        : IN  STD_LOGIC;
   		 -- CONTROL PORTS --------------------------------
          RESET      : IN  STD_LOGIC;
					ONE_CT : in STD_LOGIC;
					read_in : inOUT std_logic;
					DECRYPT : IN std_logic;
          DONE1       : OUT STD_LOGIC;
					DONE2_out       : OUT STD_LOGIC;
   	    -- KEY PORT -------------------------------------
				KEY : in 	STD_LOGIC_VECTOR((GET_TWEAKEY_FACT(BS, TS)*get_BLOCK_SIZE(BS)/16 - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          PLAINTEXT  : IN  STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS)/16 - 1) DOWNTO 0);
					CIPHERTEXT1 : OUT STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS)) - 1) DOWNTO 0));
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
	 SIGNAL FORK   : STD_LOGIC;

	 signal ROUND_KEY		:	STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*get_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
	SIGNAL KEY_word : STD_LOGIC_VECTOR((GET_TWEAKEY_FACT(BS,TS)*GET_BLOCK_SIZE(BS)/16)-1 downto 0);
	SIGNAL ROUND_CST : STD_LOGIC_VECTOR(((N / 16) - 1) DOWNTO 0);
	SIGNAL Branch_constant : STD_LOGIC_VECTOR(((N / 16) - 1) DOWNTO 0);
	SIGNAL STATE : STD_LOGIC_VECTOR(((N) - 1) DOWNTO 0);
	SIGNAL MUX_PLAINTEXT : STD_LOGIC_VECTOR(((N) - 1) DOWNTO 0);
	SIGNAL FORKSTATE : STD_LOGIC_VECTOR(((N) - 1) DOWNTO 0);
	SIGNAL state_read	:  STD_LOGIC;
	SIGNAL RF_clk       : STD_LOGIC;
	SIGNAL no_clk       : STD_LOGIC;
	SIGNAL branch_cst_enable       : STD_LOGIC;
	SIGNAL mux_out  :  STD_LOGIC_VECTOR(W-1 downto 0);
	SIGNAL RF_in  :  STD_LOGIC_VECTOR(W-1 downto 0);
	SIGNAL DONE  :STD_LOGIC;
	SIGNAL CLK_CE_RF, CLK_GATE_RF		: STD_LOGIC;
	signal done2 : std_logic;
	signal msb_state : STD_LOGIC_vector(get_BLOCK_SIZE(BS)/16 - 1 downto 0);
	signal msb_FORK_state : STD_LOGIC_vector(get_BLOCK_SIZE(BS)/16 - 1 downto 0);
	signal forkstate_enable : std_logic;
	signal decrypt_rf : std_logic;
	signal DECRYPT_KE : std_logic;
	signal KE_READ : std_logic;
	signal retracing : std_logic;
	signal done_total : std_logic;
	signal KE_EVEN_RESET : std_logic;
BEGIN
  done1<=done;
	done2_out <= done2;
	done_total <= done or done2;
	-- ROUND FUNCTION -------------------------------------------------------------
forkstate_enable <= fork or read_in;

KE_READ <= '1' when no_clk = '0' and read_in = '1' else '0';

	CLK_CE_RF <= '1' WHEN ((no_clk = '0') or (state_read = '1')) ELSE '0';
	msb_state <= state(get_BLOCK_SIZE(BS)-1 downto 15*get_BLOCK_SIZE(BS)/16 );
  msb_FORK_state <= FORKSTATE(get_BLOCK_SIZE(BS)-1 downto 15*get_BLOCK_SIZE(BS)/16 );

	RF_in <= PLAINTEXT when (read_in = '1' and done = '0') ELSE msb_FORK_state;
	MUX_PLAINTEXT <=  FORKSTATE;
	RF : ENTITY work.RoundFunction GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK,read_in,decrypt_rf,CLK_CE_RF, ROUND_CTL, round_CST ,BRANCH_constant, ROUND_KEY, RF_in ,State);

	FORKSTATEreg : entity work.fork_reg GENERIC MAP (BS => BS) PORT MAP (clk, msb_state, forkstate_enable, FORKSTATE);

--	mux : entity work.word_mux GENERIC MAP (BS => BS, TS => TS) PORT MAP (clk, MUX_PLAINTEXT,mux_out,COUNTER);


	CIPHERTEXT1 <= STATE;

	DECRYPT_KE <= retracing;
	DECRypt_RF <= retracing;

KE_EVEN_RESET <= done and done2;

	-------------------------------------------------------------------------------
	BRANCH_LFSR : ENTITY work.lfsr_counter GENERIC MAP (BS => BS) PORT MAP (CLK, BRANCH_cst_enable, Branch_constant);
   -- KEY EXPANSION --------------------------------------------------------------
   KE : ENTITY work.KeyExpansion  GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, KE_READ,KE_EVEN_RESET,DECRYPT_KE,decrypt,KEY_CTL,done_total, KEY, ROUND_KEY);
	-------------------------------------------------------------------------------

   -- CONTROL LOGIC --------------------------------------------------------------
   CL : ENTITY work.ControlLogic GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET,ONE_CT, DECRYPT,retracing,DONE,DONE2,read_in,FORK, ROUND_CTL,KEY_CTL, ROUND_CST,state_read,no_clk, branch_cst_enable);
	-------------------------------------------------------------------------------



END Structural;
