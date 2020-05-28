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
		    DONE			: INOUT STD_LOGIC;
			 ROUND_CTL	: INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 KEY_CTL 	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 FORK_REACHED : INout std_logic;
			 no_clk_is : out std_logic;
			 -- CONST PORT -----------------------------------
          ROUND_CST  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
					branch_cst_enable_out : INOUT  std_logic);
END ControlLogic;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF ControlLogic IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, UPDATE : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL COUNTER			: INTEGER RANGE 0 TO 20;
	signal CT_READ : std_logic;
	signal branch_cst_enable : std_logic;
BEGIN
branch_cst_enable_out <= branch_cst_enable and CT_READ;
	-- CONTROL LOGIC --------------------------------------------------------------
decr_64_192: IF BS = BLOCK_SIZE_64  AND TS = TWEAKEY_SIZE_192 GENERATE
	FORK_REACHED <= '1' when (update = "1001111" and round_ctl(0) = '0') and CT_READ = '1' else '0';
	Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
			no_clk_is <= '0';
			CT_READ <= '0';
			branch_cst_enable <= '0';
		elsif(counter = 20) and (FORK_REACHED = '1') then
			no_clk_is <= '1';
		elsif (counter = 20) and  (update = "0100110") and (CT_READ = '1') THEN
			branch_cst_enable <= '1';
						no_clk_is <= '0';
		elsif (counter = 15) and  (update = "0100110") THEN
			CT_READ <= '1';
		elsif(update /= "0100110") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
	end generate;

decr_128_1N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_192 GENERATE
	FORK_REACHED <= '1' when (update = "1110101" and round_ctl(0) = '0')  and CT_READ = '1' else '0';
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
		no_clk_is <= '0';

					CT_READ <= '0';
			branch_cst_enable <= '0';
		elsif(counter = 20) and (FORK_REACHED = '1') then
			no_clk_is <= '1';
		elsif (counter = 20) and  (update = "0101011") and (CT_READ = '1') THEN
			branch_cst_enable <= '1';
						no_clk_is <= '0';
		elsif (counter = 15) and  (update = "0101011") THEN
			CT_READ <= '1';
		elsif(update /= "0101011") then
			branch_cst_enable <= '0';
		end if;
	end if;
end process;
end generate;
decr_128_2N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_256 GENERATE
	FORK_REACHED <= '1' when (update = "1110101" and round_ctl(0) = '0')  and CT_READ = '1' else '0';
	Process(clk) BEGIN
		if(RISING_EDGE(clk)) THEN
			if(reset = '1') THEN
			no_clk_is <= '0';

						CT_READ <= '0';
				branch_cst_enable <= '0';
			elsif(counter = 20) and (FORK_REACHED = '1') then
				no_clk_is <= '1';
			elsif (counter = 20) and  (update = "0101011") and (CT_READ = '1')THEN
				branch_cst_enable <= '1';
							no_clk_is <= '0';
			elsif (counter = 15) and  (update = "0101011") THEN
				CT_READ <= '1';
			elsif(update /= "0101011") then
				branch_cst_enable <= '0';
			end if;
		end if;
	end process;
end generate;
decr_128_3N: IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_288 GENERATE
	FORK_REACHED <= '1' when (update = "1011100" and round_ctl(0) = '0')  and CT_READ = '1' else '0';
Process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
		if(reset = '1') THEN
		no_clk_is <= '0';
					CT_READ <= '0';
			branch_cst_enable <= '0';
		elsif(counter = 20) and (FORK_REACHED = '1') then
			no_clk_is <= '1';
		elsif (counter = 20) and  (update = "0000101") and (CT_READ = '1') THEN
			branch_cst_enable <= '1';
						no_clk_is <= '0';
		elsif (counter = 15) and  (update = "0000101") THEN
			CT_READ <= '1';
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
			elsif(done = '1') and counter = 15 THEN
				counter <= 0;
			ELSE
				COUNTER <= COUNTER + 1;
			END IF;
		END IF;
	END PROCESS;

	KEY_CTL(0) 	 <= '0' when done = '1' else '1' WHEN ((COUNTER < 8) )  ELSE '0';
	KEY_CTL(1)	 <= '0' when done = '1' else '1' WHEN ((COUNTER = 16) ) ELSE '0';

	ROUND_CTL(0) <= '0' when done = '1' else '1' WHEN ((COUNTER = 16) ) ELSE '0';
	ROUND_CTL(1) <= '0' when done = '1' else '1' WHEN ((COUNTER > 16) )ELSE '0';

	-- CONST: STATE ---------------------------------------------------------------
	REG : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				STATE <= (OTHERS => '0');
			elsif (counter = 15) and (done = '1') and (CT_READ = '0') then
				STATE <= (OTHERS => '0');
			ELSIF (counter = 16) THEN
				STATE <= UPDATE;
			END IF;
		END IF;
	END PROCESS;

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE <= STATE(5 DOWNTO 0) & (STATE(6) XNOR STATE(5));

	-- CONSTANT -------------------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0)) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0)) ELSE UPDATE(6) WHEN (COUNTER = 4)  else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0)) ELSE UPDATE(5) WHEN ((COUNTER = 4) )  ELSE '1' WHEN ((COUNTER = 8) )  ELSE '1' WHEN ((COUNTER = 2) )  ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0)) ELSE UPDATE(4) WHEN ((COUNTER = 4) )  ELSE '0';
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		ROUND_CST(7 DOWNTO 4) <= "0000";
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0)) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0)) ELSE UPDATE(6) WHEN(COUNTER = 4) else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0)) ELSE UPDATE(5) WHEN ((COUNTER = 4))  ELSE '1' WHEN ((COUNTER = 8) ) ELSE '1' WHEN ((COUNTER = 2))  ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0)) ELSE UPDATE(4) WHEN ((COUNTER = 4))  ELSE '0';
	END GENERATE;

	-- DONE SIGNAL ----------------------------------------------------------------
	CHK_64_3N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAKEY_SIZE_192 GENERATE DONE <= '1' WHEN ((UPDATE = "0100110" AND COUNTER < 16 and CT_READ = '0') ) or ((UPDATE = "1110001" AND COUNTER < 16)) ELSE '0'; END GENERATE;
	CHK_128_1N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_192 GENERATE DONE <= '1' WHEN ((UPDATE = "0101011" AND COUNTER < 16 and CT_READ = '0') ) or ((UPDATE = "0110010" AND COUNTER < 16))  ELSE '0'; END GENERATE;
	CHK_128_2N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_256 GENERATE DONE <= '1' WHEN ((UPDATE = "0101011" AND COUNTER < 16 and CT_READ = '0') ) or ((UPDATE = "0110010" AND COUNTER < 16))  ELSE '0'; END GENERATE;
	CHK_128_3N : IF BS = BLOCK_SIZE_128 AND TS = TWEAKEY_SIZE_288 GENERATE DONE <= '1' WHEN ((UPDATE = "0000101" AND COUNTER < 16 and CT_READ = '0') ) or ((UPDATE = "0100001" AND COUNTER < 16))  ELSE '0'; END GENERATE;

END Round;
