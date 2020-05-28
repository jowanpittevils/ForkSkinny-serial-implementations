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
ENTITY RoundFunction IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAKEY_SIZE 		 := TWEAKEY_SIZE_192);
   PORT ( CLK        : IN  STD_LOGIC;
   		 -- CONTROL PORTS --------------------------------
          RESET      : IN  STD_LOGIC;
					DECRYPT    : IN STD_LOGIC;
					RF_enable  : in std_logic;
          ROUND_CTL  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
   	    -- CONSTANT PORT --------------------------------
          ROUND_CST  : IN  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 16) - 1) DOWNTO 0);
					Branch_cst : in STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 16) - 1) DOWNTO 0);
   	    -- KEY PORT -------------------------------------
				ROUND_KEY		: IN	STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*get_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);   	    -- DATA PORTS -----------------------------------
          ROUND_IN   : IN  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 16) - 1) DOWNTO 0);
          ROUND_OUT  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   ) - 1) DOWNTO 0));
END RoundFunction;



-- ARCHITECTURE : ROW
----------------------------------------------------------------------------------
ARCHITECTURE Row OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAKEY_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, SHIFTROWS, SHIFTED, STATE_NEXT, SHIFTROWS_inv : STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL SUBSTITUTE, ADDITION, SUBSTITUTE_inv, ADDITION_inv, addition_input,branch_added: STD_LOGIC_VECTOR(( 1 * W - 1) DOWNTO 0);
	SIGNAL COLUMN, COLUMN_inv,MIXCOLUMN,MIXCOLUMN_inv				: STD_LOGIC_VECTOR(( 4 * W - 1) DOWNTO 0);

BEGIN

   -- SIGNAL ASSIGNMENTS ---------------------------------------------------------
   COLUMN <= STATE((16 * W - 1) DOWNTO (15 * W)) & STATE((12 * W - 1) DOWNTO (11 * W)) & STATE((8 * W - 1) DOWNTO (7 * W)) & STATE((4 * W - 1) DOWNTO (3 * W));
	 COLUMN_inv <= STATE((13 * W - 1) DOWNTO (12 * W)) & STATE((9 * W - 1) DOWNTO (8 * W)) & STATE((5 * W - 1) DOWNTO (4 * W)) & STATE((1 * W - 1) DOWNTO (0 * W));

	 -- REGISTER STAGES ------------------------------------------------------------
 	C15 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((16 * W - 1) DOWNTO (15 * W)), SHIFTED((16 * W - 1) DOWNTO (15 * W)), STATE((16 * W - 1) DOWNTO (15 * W)));
 	--ROUND_CTL(0) is meestal 0
 	C14 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((15 * W - 1) DOWNTO (14 * W)), SHIFTED((15 * W - 1) DOWNTO (14 * W)), STATE((15 * W - 1) DOWNTO (14 * W)));
 	C13 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((14 * W - 1) DOWNTO (13 * W)), SHIFTED((14 * W - 1) DOWNTO (13 * W)), STATE((14 * W - 1) DOWNTO (13 * W)));
 	C12 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((13 * W - 1) DOWNTO (12 * W)), SHIFTED((13 * W - 1) DOWNTO (12 * W)), STATE((13 * W - 1) DOWNTO (12 * W)));

 	C11 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((12 * W - 1) DOWNTO (11 * W)), SHIFTED((12 * W - 1) DOWNTO (11 * W)), STATE((12 * W - 1) DOWNTO (11 * W)));
 	C10 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((11 * W - 1) DOWNTO (10 * W)), SHIFTED((11 * W - 1) DOWNTO (10 * W)), STATE((11 * W - 1) DOWNTO (10 * W)));
 	C09 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT((10 * W - 1) DOWNTO ( 9 * W)), SHIFTED((10 * W - 1) DOWNTO ( 9 * W)), STATE((10 * W - 1) DOWNTO ( 9 * W)));
 	C08 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 9 * W - 1) DOWNTO ( 8 * W)), SHIFTED(( 9 * W - 1) DOWNTO ( 8 * W)), STATE(( 9 * W - 1) DOWNTO ( 8 * W)));

 	C07 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 8 * W - 1) DOWNTO ( 7 * W)), SHIFTED(( 8 * W - 1) DOWNTO ( 7 * W)), STATE(( 8 * W - 1) DOWNTO ( 7 * W)));
 	C06 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 7 * W - 1) DOWNTO ( 6 * W)), SHIFTED(( 7 * W - 1) DOWNTO ( 6 * W)), STATE(( 7 * W - 1) DOWNTO ( 6 * W)));
 	C05 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 6 * W - 1) DOWNTO ( 5 * W)), SHIFTED(( 6 * W - 1) DOWNTO ( 5 * W)), STATE(( 6 * W - 1) DOWNTO ( 5 * W)));
 	C04 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 5 * W - 1) DOWNTO ( 4 * W)), SHIFTED(( 5 * W - 1) DOWNTO ( 4 * W)), STATE(( 5 * W - 1) DOWNTO ( 4 * W)));

 	C03 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable,	STATE_NEXT(( 4 * W - 1) DOWNTO ( 3 * W)), SHIFTED(( 4 * W - 1) DOWNTO ( 3 * W)), STATE(( 4 * W - 1) DOWNTO ( 3 * W)));
 	C02 : ENTITY work.DataFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,RF_enable, 								STATE_NEXT(( 3 * W - 1) DOWNTO ( 2 * W)), STATE(( 3 * W - 1) DOWNTO ( 2 * W)));
 	C01 : ENTITY work.DataFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,RF_enable, 								STATE_NEXT(( 2 * W - 1) DOWNTO ( 1 * W)), STATE(( 2 * W - 1) DOWNTO ( 1 * W)));
 	C00 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK,(ROUND_CTL(0)),RF_enable, STATE_NEXT(( 1 * W - 1) DOWNTO ( 0 * W)), SHIFTED(( 1 * W - 1) DOWNTO ( 0 * W)), STATE(( 1 * W - 1) DOWNTO ( 0 * W)));

	-- SUBSTITUTION ---------------------------------------------------------------
	branch_added <= STATE((16 * W - 1) DOWNTO (15 * W)) xor branch_cst;
	S : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (branch_added, SUBSTITUTE);
	S_inv : ENTITY work.SBox_dec GENERIC MAP (BS => BS) PORT MAP (ADDITION, SUBSTITUTE_inv);
	-- CONSTANT AND KEY ADDITION ---- ----------------------------------------------
	addition_input <=  SUBSTITUTE WHEN (decrypt = '0') ELSE STATE(1*W-1 downto 0);

	KA : ENTITY work.AddConstKey GENERIC MAP (BS => BS, TS => TS) PORT MAP (ROUND_CST,ROUND_KEY, addition_input, ADDITION);

	-- SHIFT ROWS -----------------------------------------------------------------
	SR : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (STATE, SHIFTROWS);
  SR_inv : ENTITY work.ShiftRows_inv GENERIC MAP (BS => BS) PORT MAP (STATE, SHIFTROWS_inv);
		SHIFTED <= SHIFTROWS when (decrypt = '0') else SHIFTROWS_inv;
	-- MIX COLUMNS ----------------------------------------------------------------
	MC : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (COLUMN, MIXCOLUMN);
  MC_inv : ENTITY work.MixColumns_inv GENERIC MAP (BS => BS) PORT MAP (COLUMN_inv, MIXCOLUMN_inv);
   -- MULTIPLEXERS ---------------------------------------------------------------


	 STATE_NEXT((16 * W - 1) DOWNTO (12 * W)) <= STATE((15 * W - 1) DOWNTO (12 * W)) & MIXCOLUMN((4 * W - 1) DOWNTO (3 * W)) WHEN (ROUND_CTL(1) = '1' and decrypt = '0')
	 ELSE STATE((15 * W - 1) DOWNTO (11 * W)) when (decrypt = '0') or (reset = '1')
	 ELSE MIXCOLUMN_inv((4 * W - 1)  DOWNTO (3 * W)) & STATE((16 * W - 1) DOWNTO (13 * W)) WHEN ((round_ctl(1) = '1') and (decrypt = '1'))
	 ELSE SUBSTITUTE_inv & STATE(16*w-1 downto 13*w) ;

	 STATE_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= STATE((11 * W - 1) DOWNTO ( 8 * W)) & MIXCOLUMN((3 * W - 1) DOWNTO (2 * W)) WHEN (ROUND_CTL(1) = '1' and decrypt = '0')
	 ELSE STATE((11 * W - 1) DOWNTO ( 7 * W)) when (decrypt = '0') or (reset = '1')
	 ELSE MIXCOLUMN_inv((3 * W - 1)  DOWNTO (2 * W)) & STATE((12 * W - 1) DOWNTO (9 * W)) WHEN ((round_ctl(1) = '1') and (decrypt = '1'))
	 ELSE STATE((13 * W - 1) DOWNTO ( 9 * W));

	 STATE_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= STATE(( 7 * W - 1) DOWNTO ( 4 * W)) & MIXCOLUMN((2 * W - 1) DOWNTO (1 * W)) WHEN (ROUND_CTL(1) = '1' and decrypt = '0')
	 ELSE STATE(( 7 * W - 1) DOWNTO ( 3 * W))when (decrypt = '0') or (reset = '1')
	 ELSE MIXCOLUMN_inv((2 * W - 1)  DOWNTO (1 * W)) & STATE((8 * W - 1) DOWNTO (5 * W)) WHEN ((round_ctl(1) = '1') and (decrypt = '1'))
	 ELSE STATE(( 9 * W - 1) DOWNTO ( 5 * W));

	 STATE_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= STATE(( 3 * W - 1) DOWNTO ( 0 * W)) & MIXCOLUMN((1 * W - 1) DOWNTO (0 * W)) WHEN (ROUND_CTL(1) = '1' and decrypt = '0')
	 ELSE STATE(( 3 * W - 1) DOWNTO ( 0 * W)) & ROUND_IN WHEN ((RESET = '1'))
	 ELSE STATE(( 3 * W - 1) DOWNTO ( 0 * W)) & ADDITION when (decrypt = '0')
	 ELSE MIXCOLUMN_inv((1 * W - 1)  DOWNTO (0 * W)) & STATE((4 * W - 1) DOWNTO (1 * W)) WHEN ((round_ctl(1) = '1') and (decrypt = '1'))
	 ELSE STATE((5 * W - 1) DOWNTO ( 1 * W));
	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= STATE;

END Row;
