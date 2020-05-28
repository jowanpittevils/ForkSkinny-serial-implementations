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
ENTITY ControlLogic IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAKEY_SIZE 		 := TWEAKEY_SIZE_192);
	PORT ( CLK		: IN	STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
		  	 RESET		: IN  STD_LOGIC;
				 DECRYPT : in STD_LOGIC;
		    DONE			: OUT STD_LOGIC;
			 ROUND_CTL	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 KEY_CTL 	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 -- CONST PORT -----------------------------------
          ROUND_CST_out  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
					retracing : INOUT std_logic;
					branch_cst_enable : INOUT  std_logic;
					updating_key : INout std_logic);
END ControlLogic;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF ControlLogic IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, UPDATE : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL COUNTER			: INTEGER RANGE 0 TO 20;
	signal updating_key_delayed : std_logic;
	signal retracing_delayed : std_logic;
	signal decrypt_update : std_logic;
	signal PT_done : std_logic;
	SIGNAL pt_DONE_delayed : std_logic;
	signal ROUND_CST  :  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
BEGIN
rndcst2 : if BS = BLOCK_SIZE_128 generate
	ROUND_CST_out <= ROUND_CST when (PT_done = PT_done_delayed) else "00000001";
end generate;
rndcst1 : if BS = BLOCK_SIZE_64 generate
	ROUND_CST_out <= ROUND_CST when (PT_done = PT_done_delayed) else "0001";
end generate;

process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
			updating_key_delayed <= updating_key;
			retracing_delayed <= retracing;
			pt_DONE_delayed <= pt_DONE;
	end if;
end process;
	-- CONTROL LOGIC --------------------------------------------------------------
decrypt_update <= retracing;
decr_64_192: IF BS = BLOCK_SIZE_64  AND TS = TWEAKEY_SIZE_192 GENERATE
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
			retracing <= '0';
			branch_cst_enable <= '0';
			PT_done <= '0';
			if(decrypt = '1') THEN
				updating_key <= '1';
			else
				updating_key <= '0';
			end if;
		elsif (counter = 20) and (update = "0100110") and (((PT_done = '0') and (decrypt = '1')) or (updating_key = '0'))THEN
			retracing <= '1';
			updating_key <= '0';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0100110") THEN
			updating_key <= '0';
			branch_cst_enable <= '1';
		elsif (counter = 20) and  (update = "1001111")  and (retracing = '1') and((pt_done = '1') or (decrypt = '0')) THEN
			retracing <= '0';
			updating_key <= '1';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0000001")  and (retracing = '1') and (decrypt = '1') and (pt_done = '0') THEN
			retracing <= '0';
			updating_key <= '0';
			branch_cst_enable <= '0';
			PT_done <= '1';
		elsif(update /= "0100110") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
	end generate;




decr_128_1N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_192 GENERATE
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
			retracing <= '0';
			branch_cst_enable <= '0';
			PT_done <= '0';
			if(decrypt = '1') THEN
				updating_key <= '1';
			else
				updating_key <= '0';
			end if;
		elsif (counter = 20) and (update = "0101011") and (((PT_done = '0') and (decrypt = '1')) or (updating_key = '0'))THEN
			retracing <= '1';
			updating_key <= '0';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0101011") THEN
			updating_key <= '0';
			branch_cst_enable <= '1';
		elsif (counter = 20) and  (update = "1110101")  and (retracing = '1') and((pt_done = '1') or (decrypt = '0')) THEN
			retracing <= '0';
			updating_key <= '1';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0000001")  and (retracing = '1') and (decrypt = '1') and (pt_done = '0') THEN
			retracing <= '0';
			updating_key <= '0';
			branch_cst_enable <= '0';
			PT_done <= '1';
		elsif(update /= "0101011") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
end generate;






decr_128_2N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_256 GENERATE
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
			retracing <= '0';
			branch_cst_enable <= '0';
			PT_done <= '0';
			if(decrypt = '1') THEN
				updating_key <= '1';
			else
				updating_key <= '0';
			end if;
		elsif (counter = 20) and (update = "0101011") and (((PT_done = '0') and (decrypt = '1')) or (updating_key = '0'))THEN
			retracing <= '1';
			updating_key <= '0';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0101011") THEN
			updating_key <= '0';
			branch_cst_enable <= '1';
		elsif (counter = 20) and  (update = "1110101")  and (retracing = '1') and((pt_done = '1') or (decrypt = '0')) THEN
			retracing <= '0';
			updating_key <= '1';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0000001")  and (retracing = '1') and (decrypt = '1') and (pt_done = '0') THEN
			retracing <= '0';
			updating_key <= '0';
			branch_cst_enable <= '0';
			PT_done <= '1';
		elsif(update /= "0101011") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
end generate;
decr_128_3N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_288 GENERATE
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
			retracing <= '0';
			branch_cst_enable <= '0';
			PT_done <= '0';
			if(decrypt = '1') THEN
				updating_key <= '1';
			else
				updating_key <= '0';
			end if;
		elsif (counter = 20) and (update = "0000101") and (((PT_done = '0') and (decrypt = '1')) or (updating_key = '0'))THEN
			retracing <= '1';
			updating_key <= '0';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0000101") THEN
			updating_key <= '0';
			branch_cst_enable <= '1';
		elsif (counter = 20) and  (update = "1011100")  and (retracing = '1') and((pt_done = '1') or (decrypt = '0')) THEN
			retracing <= '0';
			updating_key <= '1';
			branch_cst_enable <= '0';
		elsif (counter = 20) and  (update = "0000001")  and (retracing = '1') and (decrypt = '1') and (pt_done = '0') THEN
			retracing <= '0';
			updating_key <= '0';
			branch_cst_enable <= '0';
			PT_done <= '1';
		elsif(update /= "0000101") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
end generate;



	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1' OR COUNTER = 20) THEN
				COUNTER <= 0;
			ELSE
				COUNTER <= COUNTER + 1;
			END IF;
		END IF;
	END PROCESS;

	KEY_CTL(0) 	 <= '1' WHEN ((COUNTER < 8) and (((retracing = '0') ) or (updating_key = '1'))) or (((COUNTER > 12)) and ((retracing = '1'))) ELSE '0';
	KEY_CTL(1)	 <= '1' WHEN ((COUNTER = 16) and (((retracing = '0') ) or (updating_key = '1'))) or ((COUNTER = 4) and ((retracing = '1'))) ELSE '0';

	ROUND_CTL(0) <= '1' WHEN ((COUNTER = 16) and ((retracing = '0') )) or ((COUNTER = 4) and ((retracing = '1') )) ELSE '0';
	ROUND_CTL(1) <= '1' WHEN ((COUNTER > 16) and ((retracing = '0') )) or (((COUNTER < 4)) and ((retracing = '1'))) ELSE '0';

	-- CONST: STATE ---------------------------------------------------------------
	REG : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				STATE <= (OTHERS => '0');
			elsif(PT_DONE = '1') and PT_done_delayed = '0' THEN
				STATE <=  (STATE(1) xnor (STATE(0) XNOR STATE(6))) & (STATE(0) XNOR STATE(6)) & STATE(6 downto 2);
 			elsif(retracing_delayed = '1') and (updating_key = '1') THEN
				STATE <=  (STATE(1) xnor (STATE(0) XNOR STATE(6))) & (STATE(0) XNOR STATE(6)) & STATE(6 downto 2);
			elsif (retracing = '1') and (retracing_delayed = '0') THEN
				state <= STATE(4 DOWNTO 0) & (STATE(6) XNOR STATE(5)) & (state(5) xnor state(4));
			elsif((updating_key = '0') and (updating_key_delayed = '1')) and decrypt = '1' and PT_done = '0' THEN
				state <= STATE(4 DOWNTO 0) & (STATE(6) XNOR STATE(5)) & (state(5) xnor state(4));
			elsif((updating_key = '0') and (updating_key_delayed = '1')) THEN
				state <= STATE;
			ELSIF (((updating_key = '1') or (decrypt = '0') or (PT_done = '1')) and (COUNTER = 16) and (retracing = '0')) or (((retracing = '1') or ((updating_key = '0') and (decrypt = '1') and (PT_done = '0')))	 and (COUNTER = 4))  THEN
				STATE <= UPDATE;
			END IF;
		END IF;
	END PROCESS;

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE <=  STATE(5 DOWNTO 0) & (STATE(6) XNOR STATE(5)) when (updating_key = '1') or ((retracing = '0') and ((pt_done = '1') OR (decrypt = '0'))) else STATE when ((updating_key = '0') and (updating_key_delayed = '1')) or ((retracing = '1')and(retracing_delayed = '0')) else (STATE(0) XNOR STATE(6)) & STATE(6 downto 1);

	-- CONSTANT -------------------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(6) WHEN(decrypt_update = '0') and (COUNTER = 4) ELSE UPDATE(6) WHEN(decrypt_update = '1') and (COUNTER = 16) else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(5) WHEN ((COUNTER = 4) and (decrypt_update = '0')) or ((COUNTER = 16) and (decrypt_update = '1')) ELSE '1' WHEN ((COUNTER = 8) and (decrypt_update = '0')) or ((COUNTER = 12) and (decrypt_update = '1')) ELSE '1' WHEN ((COUNTER = 2) and (decrypt_update = '0')) or ((COUNTER = 18) and (decrypt_update = '1')) ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(4) WHEN ((COUNTER = 4) and (decrypt_update = '0')) or ((COUNTER = 16) and (decrypt_update = '1')) ELSE '0';
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		ROUND_CST(7 DOWNTO 4) <= "0000";
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(6) WHEN(decrypt_update = '0') and (COUNTER = 4) ELSE UPDATE(6) WHEN(decrypt_update = '1') and (COUNTER = 16) else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(5) WHEN ((COUNTER = 4) and (decrypt_update = '0')) or ((COUNTER = 16) and (decrypt_update = '1')) ELSE '1' WHEN ((COUNTER = 8) and (decrypt_update = '0')) or ((COUNTER = 12) and (decrypt_update = '1')) ELSE '1' WHEN ((COUNTER = 2) and (decrypt_update = '0')) or ((COUNTER = 18) and (decrypt_update = '1')) ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0) and (decrypt_update = '0')) or ((COUNTER = 20) and (decrypt_update = '1')) ELSE UPDATE(4) WHEN ((COUNTER = 4) and (decrypt_update = '0')) or ((COUNTER = 16) and (decrypt_update = '1')) ELSE '0';
	END GENERATE;

	-- DONE SIGNAL ----------------------------------------------------------------
	CHK_64_3N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAKEY_SIZE_192 GENERATE DONE <= '1' WHEN ((UPDATE = "0100110" AND COUNTER < 16) and (decrypt = '0') and (retracing = '1')) or ((UPDATE = "1110001" AND COUNTER < 16) and ((PT_DONE = '1') or (decrypt = '0')) and (retracing = '0')) or (((UPDATE = "0000001" AND COUNTER = 0) ) and (decrypt = '1') and (updating_key = '0')) ELSE '0'; END GENERATE;
	CHK_128_1N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_192 GENERATE DONE <= '1' WHEN ((UPDATE = "0101011" AND COUNTER < 16) and (decrypt = '0')and (retracing = '1')) or ((UPDATE = "0110010" AND COUNTER < 16) and ((PT_DONE = '1') or (decrypt = '0')) and (retracing = '0'))  or (((UPDATE = "0000001" AND COUNTER = 0) ) and (decrypt = '1') and (updating_key = '0')) ELSE '0'; END GENERATE;
	CHK_128_2N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_256 GENERATE DONE <= '1' WHEN ((UPDATE = "0101011" AND COUNTER < 16) and (decrypt = '0')and (retracing = '1')) or ((UPDATE = "0110010" AND COUNTER < 16) and ((PT_DONE = '1') or (decrypt = '0')) and (retracing = '0'))  or (((UPDATE = "0000001" AND COUNTER = 0) ) and (decrypt = '1') and (updating_key = '0')) ELSE '0'; END GENERATE;
	CHK_128_3N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_288 GENERATE DONE <= '1' WHEN ((UPDATE = "0000101" AND COUNTER < 16) and (decrypt = '0')and (retracing = '1')) or ((UPDATE = "0100001" AND COUNTER < 16) and ((PT_DONE = '1') or (decrypt = '0')) and (retracing = '0'))  or (((UPDATE = "0000001" AND COUNTER = 0) ) and (decrypt = '1') and (updating_key = '0')) ELSE '0'; END GENERATE;

END Round;
