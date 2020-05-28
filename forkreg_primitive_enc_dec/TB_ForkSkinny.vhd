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

USE WORK.ForkSKINNYPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY TB_ForkSkinny IS
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_64;
				TS : TWEAKEY_SIZE := TWEAKEY_SIZE_192);
				END TB_ForkSkinny;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF TB_ForkSkinny IS

 SIGNAL DECRYPT 		: STD_LOGIC := '1';
 signal one_CT : STD_LOGIC := '0';

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAKEY_SIZE(BS, TS);
	CONSTANT F : INTEGER := GET_TWEAKEY_FACT(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	-------------------------------------------------------------------------------

	-- TEST VECTORS ---------------------------------------------------------------
	SIGNAL TV_PT 	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL TV_CT0 	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL TV_CT1 	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL TV_KT 	: STD_LOGIC_VECTOR((GET_FULL_TWEAKEY_SIZE(BS,TS) - 1) DOWNTO 0);
	signal read_in : std_logic;
	-------------------------------------------------------------------------------

	-- INPUTS ---------------------------------------------------------------------
   SIGNAL CLK 			: STD_LOGIC := '0';
   SIGNAL RESET 		: STD_LOGIC := '0';


	 signal FIRST_C0 : STD_LOGIC := '0';
	 signal PREV_CT_AVAILABLE : std_logic := '0';

   SIGNAL KEY 			: STD_LOGIC_VECTOR(((GET_TWEAKEY_FACT(BS, TS)*GET_WORD_SIZE(BS)) - 1) DOWNTO 0);
   SIGNAL PLAINTEXT 	: STD_LOGIC_VECTOR((N)/16 - 1 DOWNTO 0);

	-------------------------------------------------------------------------------

	-- OUTPUTS --------------------------------------------------------------------
   SIGNAL CT0	      : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	 SIGNAL CT1	      : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	 SIGNAL PT	      : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL DONE1			: STD_LOGIC;
	SIGNAL DONE2			: STD_LOGIC;
	SIGNAL FORK			: STD_LOGIC;
   SIGNAL CIPHERTEXT0 : STD_LOGIC_VECTOR((N) - 1 DOWNTO 0);
   SIGNAL CIPHERTEXT : STD_LOGIC_VECTOR((N)- 1 DOWNTO 0);
	 SIGNAL prev_ct : STD_LOGIC_VECTOR((N) - 1 DOWNTO 0);
	-------------------------------------------------------------------------------

   -- CLOCK PERIOD DEFINITIONS ---------------------------------------------------
   CONSTANT CLK_PERIOD : TIME := 10 NS;
	-------------------------------------------------------------------------------

	BEGIN

		-- INSTANTIATE UNIT UNDER TEST (UUT) ------------------------------------------
	   UUT : ENTITY work.ForkSkinny
		GENERIC MAP (BS => BS, TS => TS)
		PORT MAP (
			CLK,
			RESET,
			ONE_CT,
			READ_IN,
			DECRYPT,
			DONE1,
			DONE2,
			KEY,
			PLAINTEXT,
			CIPHERTEXT
		);
		-------------------------------------------------------------------------------
--		PREV_CT <= (others => '0');
	   -- CLOCK PROCESS --------------------------------------------------------------
	   CLK_PROCESS : PROCESS
		BEGIN
			CLK <= '0'; WAIT FOR CLK_PERIOD/2;
			CLK <= '1'; WAIT FOR CLK_PERIOD/2;
	   END PROCESS;
		-------------------------------------------------------------------------------

	   -- STIMULUS PROCESS -----------------------------------------------------------
	   STIM_PROCESS : PROCESS
	   BEGIN

			----------------------------------------------------------------------------
			IF BS = BLOCK_SIZE_64 THEN

					TV_PT <= X"568115fe39845843";
					TV_CT0 <= X"880bdb4f2428557b";
					TV_CT1 <= X"95cccf4d4c7e16cb";
					TV_KT	<= X"1bef568115fe398458439000432155554444584628424546";

			ELSE
				IF 	TS = TWEAKEY_SIZE_192 THEN
				TV_PT <= X"00000000000000000000000000000000";
				TV_CT0 <= X"1266952ad0e6d0e0953a7faeeb671f3f";
				TV_CT1 <= X"b702d534552bef5ae5ffca7c9ac6db89";
				TV_KT	<=    X"000102030405060708090a0b0c0d0e0f00010203040506080001020304050608";
			--	TV_KT	<=  X"1bef568115fe3984584390004321555544445846284245466576554358965788";
				ELSIF TS = TWEAKEY_SIZE_256 THEN
				TV_PT <=  X"abcd1234abcd1234abcd1234abcd1234";
				TV_CT0 <= X"66f82db24947bf5374ea0b71902a58b8";
				TV_CT1 <= X"8d4e02ba4fdcdc3b231ab5673dfe045d";
				TV_KT	<=  X"1bef568115fe3984584390004321555544445846284245466576554358965788";
				ELSE
				TV_PT <= X"abcd1234abcd1234abcd1234abcd1234";
				TV_CT0 <= X"798020c131c5c203e2f8fdab8e282e98";
				TV_CT1 <= X"bfbe616ce54d6e0fea3bb2210bC9c6d1";
				TV_KT	<=  X"1bdf568115fe3984584390004321555544445846284245466576554358965788abcd123400000000abcd123400000000";
				END IF;
			END IF;
		----------------------------------------------------------------------------

		WAIT FOR CLK_PERIOD;
	RESET <= '1';
	wait UNTIL (read_in = '1');
		----------------------------------------------------------------------------
		if (decrypt = '0') then
			FOR I IN 0 TO 15 LOOP
					PLAINTEXT <= TV_PT((N - I * W - 1) DOWNTO (N - (I + 1) * W));


		FOR J IN 0 TO (F - 1) LOOP
			KEY(((J + 1) * W - 1) DOWNTO (J * W)) <= TV_KT((GET_FULL_TWEAKEY_SIZE(BS,TS) - J * N - I * W - 1) DOWNTO (GET_FULL_TWEAKEY_SIZE(BS,TS) - J * N - (I + 1) * W));

		END LOOP;
		wait for CLK_PERIOD;
		reset <= '0';
	END LOOP;
	RESET <= '0';
	else
		RESET <= '1';



	FOR I IN 0 TO 15 LOOP

		PLAINTEXT <= TV_CT1((N - I * W - 1) DOWNTO (N - (I + 1) * W));

		FOR J IN 0 TO (F - 1) LOOP
			KEY(((J + 1) * W - 1) DOWNTO (J * W)) <= TV_KT((GET_FULL_TWEAKEY_SIZE(BS,TS) - J * N - I * W - 1) DOWNTO (GET_FULL_TWEAKEY_SIZE(BS,TS) - J * N - (I + 1) * W));
		END LOOP;
		wait for CLK_PERIOD;
		RESET <= '0';
	END LOOP;
RESET <= '0';
		end if;

-------one_CT = '0'


		if one_CT = '0' then
     WAIT UNTIL DONE1 = '1';
	   WAIT FOR CLK_PERIOD;

		 if (decrypt = '0') then


					 CT1 <= CIPHERTEXT;
					 WAIT FOR CLK_PERIOD;


		else

					PT <= CIPHERTEXT;
					WAIT FOR CLK_PERIOD;

		end if;
		WAIT FOR CLK_PERIOD/2;

		WAIT UNTIL DONE2 = '1';

		 WAIT FOR CLK_PERIOD;

		 if (decrypt = '0') then

					 CT0  <= CIPHERTEXT;
					 WAIT FOR CLK_PERIOD;

		else

					CT0 <= CIPHERTEXT;
					WAIT FOR CLK_PERIOD;

		end if;

		---------------------------------------------------------------------------
  	 	---------------------------------------------------------------------------
		if (decrypt = '0') then
     	IF (((CT0 = TV_CT0) and (CT1 = TV_CT1)) and (FIRST_C0 = '0')) or (((CT0 = TV_CT1) and (CT1 = TV_CT0)) and (FIRST_C0 = '1')) THEN
			report "current time = " & time'image(now);
   		ASSERT FALSE REPORT "---------- BOTH CT's CORRECT ----------" SEVERITY FAILURE;
     	ELSE
         ASSERT FALSE REPORT "---------- FAILED ----------" SEVERITY FAILURE;
    	END IF;
		else
			IF ((PT = TV_PT) and (CT0 = TV_CT0)) THEN
			report "current time = " & time'image(now);
			ASSERT FALSE REPORT "---------- PT CORRECT ----------" SEVERITY FAILURE;
			ELSE
				 ASSERT FALSE REPORT "---------- FAILED ----------" SEVERITY FAILURE;
			END IF;
		end if;









-- one_CT = '1'


	else


		WAIT UNTIL DONE2 = '1';

	---------------------------------------------------------------------------
	 WAIT FOR CLK_PERIOD;

		 if (decrypt = '0') then

					 CT1<= CIPHERTEXT;
					 WAIT FOR CLK_PERIOD;

		else

					CT1 <= CIPHERTEXT;
					WAIT FOR CLK_PERIOD;

		end if;


	---------------------------------------------------------------------------

		---------------------------------------------------------------------------
	if (decrypt = '0') then
			IF ((CT1 = TV_CT1)) THEN
				report "current time = " & time'image(now);
				ASSERT FALSE REPORT "---------- SINGLE CT CORRECT ----------" SEVERITY FAILURE;
			ELSE
				 ASSERT FALSE REPORT "---------- FAILED ----------" SEVERITY FAILURE;
			END IF;
	else
		IF ((PT = TV_PT) and (CT1 = TV_CT1)) THEN
			report "current time = " & time'image(now);
			ASSERT FALSE REPORT "---------- PT CORRECT ----------" SEVERITY FAILURE;
		ELSE
			 ASSERT FALSE REPORT "---------- FAILED ----------" SEVERITY FAILURE;
		END IF;
	end if;
end if;
		---------------------------------------------------------------------------

   END PROCESS;
	-------------------------------------------------------------------------------
END;
