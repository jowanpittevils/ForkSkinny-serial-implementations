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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE WORK.ForkSkinnyPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY KeyExpansion IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAKEY_SIZE 		 := TWEAKEY_SIZE_192);
	PORT ( CLK			: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RESET		: IN  STD_LOGIC;
			 KEY_CTL		: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			 done : in std_logic;
		    -- KEY PORT -------------------------------------
				KEY        : IN STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*GET_WORD_SIZE(BS)) - 1) DOWNTO 0);
				ROUND_KEY		: OUT	STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*get_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0));
				END KeyExpansion;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF KeyExpansion IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAKEY_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CLK_H, CLK_CE_H, CLK_GATE_H,CLK_CE_HALF		: STD_LOGIC;
	SIGNAL CLK_L, CLK_CE_L, CLK_GATE_L		: STD_LOGIC;
	SIGNAL TK1, TK2, TK3							: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_NEXT, TK2_NEXT, TK3_NEXT		: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_PERM,TK1_PERM_inv,TK1_PERM_out,TK2_PERM_out, TK3_PERM_out,TK2_PERM,TK2_PERM_inv, TK3_PERM,TK3_PERM_inv,TK2_HALF,TK2_HALF_NEXT,TK3_HALF,TK3_HALF_NEXT		: STD_LOGIC_VECTOR(( 8 * W - 1) DOWNTO 0);
	SIGNAL TK1_LFSR, TK2_LFSR, TK3_LFSR	,C0_in	: STD_LOGIC_VECTOR(( 1 * W - 1) DOWNTO 0);

	signal KEY_CTL0 : std_logic;
	signal key_CTL1 : std_logic;
	signal even_round : std_logic;
BEGIN

	-- CLOCK GATING ---------------------------------------------------------------
	CLK_CE_H <= '1' WHEN (KEY_CTL(0) = '1' OR KEY_CTL(1) = '1') or (reset = '1') ELSE '0';
	CLK_CE_half <= '1' WHEN (KEY_CTL0 = '1') OR ((KEY_CTL(1) = '1') and even_round = '0' )   ELSE '0';

	CLK_CE_L <= '1' WHEN (KEY_CTL(0) = '1') or (reset = '1') ELSE '0';
	-------------------------------------------------------------------------------

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
	GEN_TK1 : IF TS = TWEAKEY_SIZE_192 OR TS = TWEAKEY_SIZE_256 OR TS = TWEAKEY_SIZE_288 GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((16 * W - 1) DOWNTO (15 * W)), TK1_PERM((8 * W - 1) DOWNTO (7 * W)), TK1((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((15 * W - 1) DOWNTO (14 * W)), TK1_PERM((7 * W - 1) DOWNTO (6 * W)), TK1((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((14 * W - 1) DOWNTO (13 * W)), TK1_PERM((6 * W - 1) DOWNTO (5 * W)), TK1((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((13 * W - 1) DOWNTO (12 * W)), TK1_PERM((5 * W - 1) DOWNTO (4 * W)), TK1((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((12 * W - 1) DOWNTO (11 * W)), TK1_PERM((4 * W - 1) DOWNTO (3 * W)), TK1((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((11 * W - 1) DOWNTO (10 * W)), TK1_PERM((3 * W - 1) DOWNTO (2 * W)), TK1((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT((10 * W - 1) DOWNTO ( 9 * W)), TK1_PERM((2 * W - 1) DOWNTO (1 * W)), TK1((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H, TK1_NEXT(( 9 * W - 1) DOWNTO ( 8 * W)), TK1_PERM((1 * W - 1) DOWNTO (0 * W)), TK1(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, 	CLK_CE_L,			TK1_NEXT(( 8 * W - 1) DOWNTO ( 7 * W)),													TK1(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,	CLK_CE_L,			 	TK1_NEXT(( 7 * W - 1) DOWNTO ( 6 * W)), 													TK1(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,	CLK_CE_L,			 	TK1_NEXT(( 6 * W - 1) DOWNTO ( 5 * W)),													TK1(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L	,			 	TK1_NEXT(( 5 * W - 1) DOWNTO ( 4 * W)),													TK1(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L	,			TK1_NEXT(( 4 * W - 1) DOWNTO ( 3 * W)), 													TK1(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, 	CLK_CE_L,			TK1_NEXT(( 3 * W - 1) DOWNTO ( 2 * W)), 													TK1(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK1_NEXT(( 2 * W - 1) DOWNTO ( 1 * W)), 													TK1(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.SCANFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, RESET,	CLK_CE_L,	TK1_NEXT(( 1 * W - 1) DOWNTO ( 0 * W)), KEY(( 1 * W - 1) DOWNTO ( 0 * W)), 	TK1(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK1((16 * W - 1) DOWNTO (8 * W)), TK1_PERM_out);
		TK1_PERM <= TK1_PERM_out ;


		-- NEXT KEY ----------------------------------------------------------------
			TK1_NEXT <= TK1((15 * W - 1) DOWNTO (0 * W)) & TK1((16 * W - 1) DOWNTO (15 * W));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY((1 * W - 1) DOWNTO (0* W)) <= TK1((16 * W - 1) DOWNTO (15 * W)) WHEN ((KEY_CTL(0)='1')) ELSE (OTHERS => '0');

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	GEN_TK2 : IF ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_64)) OR TS = TWEAKEY_SIZE_256 OR TS = TWEAKEY_SIZE_288 GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((16 * W - 1) DOWNTO (15 * W)), TK2_PERM((8 * W - 1) DOWNTO (7 * W)), TK2((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H,TK2_NEXT((15 * W - 1) DOWNTO (14 * W)), TK2_PERM((7 * W - 1) DOWNTO (6 * W)), TK2((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((14 * W - 1) DOWNTO (13 * W)), TK2_PERM((6 * W - 1) DOWNTO (5 * W)), TK2((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((13 * W - 1) DOWNTO (12 * W)), TK2_PERM((5 * W - 1) DOWNTO (4 * W)), TK2((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((12 * W - 1) DOWNTO (11 * W)), TK2_PERM((4 * W - 1) DOWNTO (3 * W)), TK2((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((11 * W - 1) DOWNTO (10 * W)), TK2_PERM((3 * W - 1) DOWNTO (2 * W)), TK2((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT((10 * W - 1) DOWNTO ( 9 * W)), TK2_PERM((2 * W - 1) DOWNTO (1 * W)), TK2((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK2_NEXT(( 9 * W - 1) DOWNTO ( 8 * W)), TK2_PERM((1 * W - 1) DOWNTO (0 * W)), TK2(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK2_NEXT(( 8 * W - 1) DOWNTO ( 7 * W)),													TK2(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK2_NEXT(( 7 * W - 1) DOWNTO ( 6 * W)), 													TK2(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK2_NEXT(( 6 * W - 1) DOWNTO ( 5 * W)),													TK2(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK2_NEXT(( 5 * W - 1) DOWNTO ( 4 * W)),													TK2(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK2_NEXT(( 4 * W - 1) DOWNTO ( 3 * W)), 													TK2(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK2_NEXT(( 3 * W - 1) DOWNTO ( 2 * W)), 													TK2(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK2_NEXT(( 2 * W - 1) DOWNTO ( 1 * W)), 													TK2(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, RESET,		 CLK_CE_L,TK2_NEXT(( 1 * W - 1) DOWNTO ( 0 * W)), KEY(( 2 * W - 1) DOWNTO ( 1 * W)), 	TK2(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK2((16 * W - 1) DOWNTO (8 * W)), TK2_PERM_out);
		TK2_PERM <= TK2_PERM_out;

		-- TK2 LFSR -----------------------------------------------------------------

		TK2_LFSR <= TK2((8 * W - 1) DOWNTO (7 * W)) WHEN (RESET = '1')
		ELSE TK2((8 * W - 2) DOWNTO (7 * W)) & (TK2(8 * W - 1) XOR TK2(8 * W - (W / 8) - 2));

		-- NEXT KEY ----------------------------------------------------------------

		TK2_NEXT <= TK2((15 * W - 1) DOWNTO (8 * W)) & TK2_LFSR & TK2(( 7 * W - 1) DOWNTO (0 * W)) & TK2((16 * W - 1) DOWNTO (15 * W));

		-- ROUND KEY ---------------------------------------------------------------

  	ROUND_KEY((2 * W - 1) DOWNTO (1* W)) <= TK2((16 * W - 1) DOWNTO (15 * W)) WHEN (KEY_CTL(0) = '1') ELSE (OTHERS => '0');

	END GENERATE;


	GEN_TK2_half : IF ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_128)) GENERATE


	KEY_CTL0 <= reset or key_CTL(0);

	-- fast forwarding
	process(KEY_CTL0,reset) BEGIN
		if(reset = '1') THEN
			even_round <= '1';
		elsif(RISING_EDGE(KEY_CTL0)) THEN
			if(done = '0') then
				even_round <= not even_round;
			end if;
		end if;
	end process;

	--clk_half <=  (CLK_H and ((not even_round) or reset));

	-- REGISTER STAGE -------------------------------------------------------------
	C07TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((8 * W - 1) DOWNTO (7 * W)), TK2_PERM((8 * W - 1) DOWNTO (7 * W)), TK2_HALF((8 * W - 1) DOWNTO (7 * W)));
	C06TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((7 * W - 1) DOWNTO (6 * W)), TK2_PERM((7 * W - 1) DOWNTO (6 * W)), TK2_HALF((7 * W - 1) DOWNTO (6 * W)));
	C05TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((6 * W - 1) DOWNTO (5 * W)), TK2_PERM((6 * W - 1) DOWNTO (5 * W)), TK2_HALF((6 * W - 1) DOWNTO (5 * W)));
	C04TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((5 * W - 1) DOWNTO (4 * W)), TK2_PERM((5 * W - 1) DOWNTO (4 * W)), TK2_HALF((5 * W - 1) DOWNTO (4 * W)));

	C03TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((4 * W - 1) DOWNTO (3 * W)), TK2_PERM((4 * W - 1) DOWNTO (3 * W)), TK2_HALF((4 * W - 1) DOWNTO (3 * W)));
	C02TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((3 * W - 1) DOWNTO (2 * W)), TK2_PERM((3 * W - 1) DOWNTO (2 * W)), TK2_HALF((3 * W - 1) DOWNTO (2 * W)));
	C01TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK2_HALF_NEXT((2 * W - 1) DOWNTO ( 1 * W)), TK2_PERM((2 * W - 1) DOWNTO (1 * W)), TK2_HALF((2 * W - 1) DOWNTO ( 1 * W)));
	C00TK2 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, C0_in, TK2_PERM((1 * W - 1) DOWNTO (0 * W)), 	TK2_HALF(( 1 * W - 1) DOWNTO ( 0 * W)));

	key_CTL1 <= ((not even_round) and KEY_CTL(1));

	C0_in <= KEY(( 2 * W - 1) DOWNTO ( 1 * W)) when (reset = '1')
	else TK2_HALF_NEXT(( 1 * W - 1) DOWNTO ( 0 * W));
	-- PERMUTATION -------------------------------------------------------------


	P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK2_HALF((8 * W - 1) DOWNTO (0 * W)), TK2_PERM_out);
	TK2_PERM <= TK2_PERM_out ;

	-- TK3 LFSR -----------------------------------------------------------------

	TK2_LFSR <=
	TK2_HALF((8 * W - 1) DOWNTO (7 * W)) WHEN ((RESET = '1') or ((even_round = '1')))
	ELSE TK2_HALF((8 * W - 2) DOWNTO (7 * W)) & (TK2_HALF(8 * W - 1) XOR TK2_HALF(8 * W - (W / 8) - 2));



	-- NEXT KEY ----------------------------------------------------------------


	TK2_HALF_NEXT <= TK2_HALF((7 * W - 1) DOWNTO (0 * W)) & TK2_LFSR;

	-- ROUND KEY ---------------------------------------------------------------
	ROUND_KEY((2 * W - 1) DOWNTO (1* W)) <= TK2_HALF((8 * W - 1) DOWNTO (7 * W)) WHEN ((KEY_CTL0 = '1') and (even_round = '1'))	ELSE (OTHERS => '0');


	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	GEN_TK3 : IF ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_64))GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT((16 * W - 1) DOWNTO (15 * W)), TK3_PERM((8 * W - 1) DOWNTO (7 * W)), TK3((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT((15 * W - 1) DOWNTO (14 * W)), TK3_PERM((7 * W - 1) DOWNTO (6 * W)), TK3((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H,TK3_NEXT((14 * W - 1) DOWNTO (13 * W)), TK3_PERM((6 * W - 1) DOWNTO (5 * W)), TK3((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT((13 * W - 1) DOWNTO (12 * W)), TK3_PERM((5 * W - 1) DOWNTO (4 * W)), TK3((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1), CLK_CE_H,TK3_NEXT((12 * W - 1) DOWNTO (11 * W)), TK3_PERM((4 * W - 1) DOWNTO (3 * W)), TK3((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT((11 * W - 1) DOWNTO (10 * W)), TK3_PERM((3 * W - 1) DOWNTO (2 * W)), TK3((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT((10 * W - 1) DOWNTO ( 9 * W)), TK3_PERM((2 * W - 1) DOWNTO (1 * W)), TK3((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, KEY_CTL(1),CLK_CE_H, TK3_NEXT(( 9 * W - 1) DOWNTO ( 8 * W)), TK3_PERM((1 * W - 1) DOWNTO (0 * W)), TK3(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK3_NEXT(( 8 * W - 1) DOWNTO ( 7 * W)),													TK3(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK3_NEXT(( 7 * W - 1) DOWNTO ( 6 * W)), 													TK3(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK3_NEXT(( 6 * W - 1) DOWNTO ( 5 * W)),													TK3(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L,				 	TK3_NEXT(( 5 * W - 1) DOWNTO ( 4 * W)),													TK3(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK,CLK_CE_L, 				TK3_NEXT(( 4 * W - 1) DOWNTO ( 3 * W)), 													TK3(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK3_NEXT(( 3 * W - 1) DOWNTO ( 2 * W)), 													TK3(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.DATAFF_Enable GENERIC MAP (SIZE => W) PORT MAP (CLK, CLK_CE_L,				TK3_NEXT(( 2 * W - 1) DOWNTO ( 1 * W)), 													TK3(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.scanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, RESET,	 CLK_CE_L,	TK3_NEXT(( 1 * W - 1) DOWNTO ( 0 * W)), KEY(( 3 * W - 1) DOWNTO ( 2 * W)), 	TK3(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P3 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK3((16 * W - 1) DOWNTO (8 * W)), TK3_PERM_out);
		TK3_PERM <= TK3_PERM_out;

		-- TK3 LFSR -----------------------------------------------------------------

		TK3_LFSR <= TK3((8 * W - 1) DOWNTO (7 * W)) WHEN (RESET = '1')
		ELSE (TK3(8 * W - (W / 8) - 1) XOR TK3(7 * W)) & TK3((8 * W - 1) DOWNTO (7 * W + 1));

		-- NEXT KEY ----------------------------------------------------------------

		TK3_NEXT <= TK3((15 * W - 1) DOWNTO (8 * W)) & TK3_LFSR & TK3(( 7 * W - 1) DOWNTO (0 * W)) & TK3((16 * W - 1) DOWNTO (15 * W));

		-- ROUND KEY ---------------------------------------------------------------

		ROUND_KEY((3 * W - 1) DOWNTO (2 * W)) <= TK3((16 * W - 1) DOWNTO (15 * W)) WHEN ((KEY_CTL(0)='1')) ELSE (OTHERS => '0');


	END GENERATE;

	GEN_TK3_half : IF (TS = TWEAKEY_SIZE_288) GENERATE
	KEY_CTL0 <= reset or key_CTL(0);

	-- fast forwarding

	KEY_CTL0 <= reset or key_CTL(0);

	-- fast forwarding
	process(KEY_CTL0,reset) BEGIN
		if(reset = '1') THEN
			even_round <= '1';
		elsif(RISING_EDGE(KEY_CTL0)) THEN
			if(done = '0') then
				even_round <= not even_round;
			end if;
		end if;
	end process;

--clk_half <=  (CLK_H and ((not even_round) or reset));

	-- REGISTER STAGE -------------------------------------------------------------
	C07TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((8 * W - 1) DOWNTO (7 * W)), TK3_PERM((8 * W - 1) DOWNTO (7 * W)), TK3_HALF((8 * W - 1) DOWNTO (7 * W)));
	C06TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((7 * W - 1) DOWNTO (6 * W)), TK3_PERM((7 * W - 1) DOWNTO (6 * W)), TK3_HALF((7 * W - 1) DOWNTO (6 * W)));
	C05TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((6 * W - 1) DOWNTO (5 * W)), TK3_PERM((6 * W - 1) DOWNTO (5 * W)), TK3_HALF((6 * W - 1) DOWNTO (5 * W)));
	C04TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((5 * W - 1) DOWNTO (4 * W)), TK3_PERM((5 * W - 1) DOWNTO (4 * W)), TK3_HALF((5 * W - 1) DOWNTO (4 * W)));

	C03TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((4 * W - 1) DOWNTO (3 * W)), TK3_PERM((4 * W - 1) DOWNTO (3 * W)), TK3_HALF((4 * W - 1) DOWNTO (3 * W)));
	C02TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((3 * W - 1) DOWNTO (2 * W)), TK3_PERM((3 * W - 1) DOWNTO (2 * W)), TK3_HALF((3 * W - 1) DOWNTO (2 * W)));
	C01TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, TK3_HALF_NEXT((2 * W - 1) DOWNTO ( 1 * W)), TK3_PERM((2 * W - 1) DOWNTO (1 * W)), TK3_HALF((2 * W - 1) DOWNTO ( 1 * W)));
	C00TK3 : ENTITY work.ScanFF_enable GENERIC MAP (SIZE => W) PORT MAP (CLK, key_CTL1,CLK_CE_HALF, C0_in, TK3_PERM((1 * W - 1) DOWNTO (0 * W)), 	TK3_HALF(( 1 * W - 1) DOWNTO ( 0 * W)));

	key_CTL1 <= ((not even_round) and KEY_CTL(1) );

	C0_in <= KEY(( 3 * W - 1) DOWNTO ( 2 * W)) when (reset = '1')
	else TK3_HALF_NEXT(( 1 * W - 1) DOWNTO ( 0 * W));
	-- PERMUTATION -------------------------------------------------------------


	P3 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK3_HALF((8 * W - 1) DOWNTO (0 * W)), TK3_PERM_out);
	TK3_PERM <= TK3_PERM_out;

	-- TK3 LFSR -----------------------------------------------------------------

	TK3_LFSR <= TK3_HALF((8 * W - 1) DOWNTO (7 * W)) WHEN ((RESET = '1') or ((even_round = '1')))
	ELSE (TK3_HALF(8 * W - (W / 8) - 1) XOR TK3_HALF(7 * W)) & TK3_HALF((8 * W - 1) DOWNTO (7 * W + 1));



	-- NEXT KEY ----------------------------------------------------------------


	TK3_HALF_NEXT <= TK3_HALF((7 * W - 1) DOWNTO (0 * W)) & TK3_LFSR;

	-- ROUND KEY ---------------------------------------------------------------


	ROUND_KEY((3 * W - 1) DOWNTO (2 * W)) <= TK3_HALF((8 * W - 1) DOWNTO (7 * W)) WHEN ((KEY_CTL0 = '1') and (even_round = '1'))
ELSE (OTHERS => '0');

END GENERATE;


END Round;
