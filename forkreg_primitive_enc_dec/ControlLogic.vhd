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
ENTITY ControlLogic IS
	GENERIC ( BS : BLOCK_SIZE;
				 TS : TWEAKEY_SIZE);
	PORT ( CLK		: IN	STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
		  	 RESET		: IN  STD_LOGIC;
				 ONE_CT : in std_logic;
				 DECRYPT : in std_logic;
				 retracing : INout std_logic;
		    DONE1			: OUT STD_LOGIC;
				DONE2			: OUT STD_LOGIC;
				read_in_out : out std_logic;
				FORK_out			: OUT STD_LOGIC;
			 ROUND_CTL	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

			 KEY_CTL 	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

			 -- CONST PORT -----------------------------------
      ROUND_CST_OUT  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);
			state_read			: OUT STD_LOGIC;
			no_clk			: OUT STD_LOGIC;
			branch_cst_enable			: OUT STD_LOGIC);
END ControlLogic;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF ControlLogic IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, UPDATE : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL FINAL			: STD_LOGIC;
--	SIGNAL COUNTER_big			: INTEGER RANGE 0 TO 200;

SIGNAL COUNTER			:  INTEGER RANGE 0 TO 20;

	SIGNAL no_clk_rndcst			: STD_LOGIC;
	SIGNAL no_clk_temp			: STD_LOGIC;
  SIGNAL COUNTER_temp			: INTEGER RANGE 0 TO 20;
	signal read_in	: std_logic;
	signal no_clk_ke : std_logic;
	signal ROUND_CST  :  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) / 16) - 1) DOWNTO 0);


	-- Build an enumerated type for the state machine
	type phase_type is (REST,INIT_encr,INIT_DECR,UPDATING_KEY,DECRYPTING,PT_READ_OUT,PRE_FORK,FORK, CT1_COMPUTE, CT1_read_out, PAUSE,START_BC, ADD_BC,CT0_COMPUTE, CT0_read_out);

		-- Register to hold the current state
	signal phase : phase_type;
	signal next_phase : phase_type;
	SIGNAL  retracing_delayed, UPDATING_KEY_SIGNAL, UPDATING_KEY_SIGNAL_DELAYED : STD_LOGIC;
BEGIN
rndcst2 : if BS = BLOCK_SIZE_128 generate
	ROUND_CST_out <= ROUND_CST when (phase /= PT_READ_OUT) else "00000001";
end generate;
rndcst1 : if BS = BLOCK_SIZE_64 generate
	ROUND_CST_out <= ROUND_CST when (phase /= PT_READ_OUT) else "0001";
end generate;
process(clk) BEGIN
	if(RISING_EDGE(clk)) THEN
			retracing_delayed <= retracing;
			UPDATING_KEY_SIGNAL_DELAYED <= UPDATING_KEY_SIGNAL;
	end if;
end process;

counter <= counter_temp;
read_in_out <= read_in;
	-- CONTROL LOGIC --------------------------------------------------------------
	PROCESS(CLK,reset) BEGIN
		if(reset = '1') THEN
			counter_temp <= 0;
		elsIF RISING_EDGE(CLK) THEN
			IF ( COUNTER_temp = 20) or ((COUNTER_TEMP = 15) and ((phase = INIT_DECR) or (phase = INIT_encr)) ) THEN
				COUNTER_temp <= 0;
			ELSE
				COUNTER_temp <= COUNTER_temp + 1;
			END IF;
		END IF;
	END PROCESS;
no_clk <= no_clk_temp;

--	PROCESS(CLK) BEGIN
--		IF RISING_EDGE(CLK) THEN
--			IF ((RESET = '1') OR (COUNTER_big = 200)) THEN
--				COUNTER_big <= 0;
--			ELSif ((COUNTER = 20)) then
--				COUNTER_big <= COUNTER_big + 1;
--			END IF;
--		END IF;
--	END PROCESS;

	KEY_CTL(0) 	 <= '0' when (no_clk_ke = '1') else '1' when (read_in = '1') else '1' WHEN ((counter_temp < 8) and ((retracing = '0') )) or (((counter_temp > 12)) and ((retracing = '1'))) ELSE '0';
	KEY_CTL(1)	 <= '0' when (no_clk_ke = '1') else '1' WHEN ((counter_temp = 16) and (((retracing = '0') ) )) or ((counter_temp = 4) and ((retracing = '1'))) ELSE '0';

	ROUND_CTL(0) <= '1' WHEN ((counter_temp = 16) and ((retracing = '0') )) or ((counter_temp = 4) and ((retracing = '1') )) ELSE '0';
	ROUND_CTL(1) <= '1' WHEN ((counter_temp > 16) and ((retracing = '0') )) or (((counter_temp < 4)) and ((retracing = '1'))) ELSE '0';



	-- CONST: STATE ---------------------------------------------------------------
	REG : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				STATE <= (OTHERS => '0');
			elsif((updating_key_signal = '0') and (updating_key_signal_delayed = '1'))  THEN
				state <= STATE(4 DOWNTO 0) & (STATE(6) XNOR STATE(5)) & (state(5) xnor state(4));
			elsif(retracing_delayed = '1') and (retracing = '0') THEN
				STATE <=  (STATE(1) xnor (STATE(0) XNOR STATE(6))) & (STATE(0) XNOR STATE(6)) & STATE(6 downto 2);
			ELSIF ((retracing = '0') and (COUNTER = 16) and (no_clk_rndcst = '0')) or ((retracing = '1') 	 and (COUNTER = 4)) THEN
				STATE <= UPDATE;
			END IF;
		END IF;
	END PROCESS;

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE <=  STATE(5 DOWNTO 0) & (STATE(6) XNOR STATE(5)) when (retracing = '0') else STATE when ((updating_key_SIGNAL = '0') and (updating_key_signal_delayed = '1')) or ((retracing = '1')and(retracing_delayed = '0')) else (STATE(0) XNOR STATE(6)) & STATE(6 downto 1);


	-- CONSTANT -------------------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(6) WHEN(retracing = '0') and (COUNTER = 4) ELSE UPDATE(6) WHEN(retracing = '1') and (COUNTER = 16) else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(5) WHEN ((COUNTER = 4) and (retracing = '0')) or ((COUNTER = 16) and (retracing = '1')) ELSE '1' WHEN ((COUNTER = 8) and (retracing = '0')) or ((COUNTER = 12) and (retracing = '1')) ELSE '1' WHEN ((COUNTER = 2) and (retracing = '0')) or ((COUNTER = 18) and (retracing = '1')) ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(4) WHEN ((COUNTER = 4) and (retracing = '0')) or ((COUNTER = 16) and (retracing = '1')) ELSE '0';
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		ROUND_CST(7 DOWNTO 4) <= "0000";
		ROUND_CST(3) <= UPDATE(3) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE '0';
		ROUND_CST(2) <= UPDATE(2) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(6) WHEN(retracing = '0') and (COUNTER = 4) ELSE UPDATE(6) WHEN(retracing = '1') and (COUNTER = 16) else '0';
		ROUND_CST(1) <= UPDATE(1) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(5) WHEN ((COUNTER = 4) and (retracing = '0')) or ((COUNTER = 16) and (retracing = '1')) ELSE '1' WHEN ((COUNTER = 8) and (retracing = '0')) or ((COUNTER = 12) and (retracing = '1')) ELSE '1' WHEN ((COUNTER = 2) and (retracing = '0')) or ((COUNTER = 18) and (retracing = '1')) ELSE '0';
		ROUND_CST(0) <= UPDATE(0) WHEN((COUNTER = 0) and (retracing = '0')) or ((COUNTER = 20) and (retracing = '1')) ELSE UPDATE(4) WHEN ((COUNTER = 4) and (retracing = '0')) or ((COUNTER = 16) and (retracing = '1')) ELSE '0';
	END GENERATE;



	-- DONE SIGNAL ----------------------------------------------------------------

	Control_signals : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
				phase <= next_phase;
		END IF;
	END PROCESS;



	phase_change64  : IF BS = BLOCK_SIZE_64 GENERATE
		process(phase,counter_temp,update,reset,one_CT)
			begin
			case(phase) is

				-- nothing happening

				WHEN REST =>
					if((reset = '1')) THEN
						if(decrypt = '0') then
							next_phase <= INIT_encr;
						else
							next_phase <= INIT_decr;
						end if;
					else
						next_phase <= REST;
					end if;

				-----

				when INIT_decr =>
					if(counter_temp = 15) THEN
						next_phase <= UPDATING_KEY;
					else
						next_phase <= INIT_decr;
					end if;
				when UPDATING_KEY =>
					if ((UPDATE = "0100110")and (COUNTER_TEMP = 20)) then
						next_phase <= DECRYPTING;
					else
						next_phase <= UPDATING_KEY;
					end if;
				when DECRYPTING =>
					if(UPDATE = "0000001") and (counter_temp = 20) THEN
						NEXT_PHASE <= PT_READ_OUT;
					else
						NEXT_PHASE <= DECRYPTING;
					end if;
				when PT_READ_OUT =>
					next_phase <= PRE_FORK;

					---


				when INIT_encr =>
					if(counter_temp = 15) THEN
						next_phase <= PRE_FORK;
					else
						next_phase <= INIT_encr;
					end if;
				when PRE_FORK =>
					if ((UPDATE = "1001111") and (COUNTER_TEMP = 20)) then -- fork is reached
						next_phase <= FORK;
					else
						next_phase <= PRE_FORK;
					end if;
				when FORK =>
					if(counter_temp = 15) then
						next_phase <= CT1_COMPUTE;
					else
						next_phase <= FORK;
					end if;
				when CT1_COMPUTE =>
					if ((UPDATE = "0100110")and (COUNTER_TEMP = 20)) then --start pause to read out data CT1 + load forkstate into roundfunction
						next_phase <= CT1_read_out;
					else
						next_phase <= CT1_COMPUTE;
					end if;
				when CT1_read_out =>
					if(ONE_CT = '0') then
						if (COUNTER_TEMP = 15) then --start computing second fork
							next_phase <= PAUSE;
						else
							next_phase <= CT1_read_out;
						end if;
					else
						if (COUNTER_TEMP = 15) then
							next_phase <= rest;
						else
							next_phase <= CT1_read_out;
						end if;
					end if;
				when PAUSE =>
					if (COUNTER_TEMP = 19) then --start computing second fork
						next_phase <= START_BC;
					else
						next_phase <= PAUSE;
					end if;
				when START_BC =>
 							--start computing second fork
					next_phase <= ADD_BC;
				when ADD_BC =>
					if (COUNTER_TEMP = 19) then -- stop adding branch constant
						next_phase <= CT0_COMPUTE;
					else
						next_phase <= ADD_BC;
					end if;
				when CT0_COMPUTE =>
					if ((UPDATE = "1110001") and (COUNTER_TEMP = 20)) then -- finished, read out CT0
						next_phase <= CT0_read_out;
					else
						next_phase <= CT0_COMPUTE;
					end if;
				when CT0_read_out =>
					if (reset = '1') then
							next_phase <= INIT_encr;
						elsif(counter_temp = 15) then
							next_phase <= rest;
						else
								next_phase <= CT0_read_out;
					end if;
				when others => next_phase <= REST;
			end case;
		end PROCESS;
	end generate;

	phase_change128192  : IF BS = BLOCK_SIZE_128  AND (TS = TWEAKEY_SIZE_192 or TS = TWEAKEY_SIZE_256) GENERATE
		process(phase,counter_temp,update,reset,one_CT)
			begin
			case(phase) is

				-- nothing happening

				WHEN REST =>
					if((reset = '1')) THEN
						if(decrypt = '0') then
							next_phase <= INIT_encr;
						else
							next_phase <= INIT_decr;
						end if;					else
						next_phase <= REST;
					end if;


				-----


				when INIT_decr =>
					if(counter_temp = 15) THEN
						next_phase <= UPDATING_KEY;
					else
						next_phase <= INIT_decr;
					end if;
				when UPDATING_KEY =>
					if ((UPDATE = "0101011")and (COUNTER_TEMP = 20)) then
						next_phase <= DECRYPTING;
					else
						next_phase <= UPDATING_KEY;
					end if;
				when DECRYPTING =>
					if(UPDATE = "0000001") and (counter_temp = 20) THEN
					NEXT_PHASE <= PT_READ_OUT;
				else
					NEXT_PHASE <= DECRYPTING;
				end if;
			when PT_READ_OUT =>
				next_phase <= PRE_FORK;
					---



				when INIT_encr =>
					if(counter_temp = 15) THEN
						next_phase <= PRE_FORK;
					else
						next_phase <= INIT_encr;
					end if;
				when PRE_FORK =>
					if ((UPDATE = "1110101") and (COUNTER_TEMP = 20)) then -- fork is reached
						next_phase <= FORK;
					else
						next_phase <= PRE_FORK;
					end if;
				when FORK =>
				if(counter_temp = 15) then
					next_phase <= CT1_COMPUTE;
				else
					next_phase <= FORK;
				end if;
				when CT1_COMPUTE =>
					if ((UPDATE = "0101011")and (COUNTER_TEMP = 20)) then --start pause to read out data CT1 + load forkstate into roundfunction
						next_phase <= CT1_read_out;
					else
						next_phase <= CT1_COMPUTE;
					end if;
				when CT1_read_out =>
				if(ONE_CT = '0') then
					if (COUNTER_TEMP = 15) then --start computing second fork
						next_phase <= PAUSE;
					else
						next_phase <= CT1_read_out;
					end if;
				else
					if (COUNTER_TEMP = 15) then
						next_phase <= rest;
					else
						next_phase <= CT1_read_out;
					end if;
				end if;
				when PAUSE =>
					if (COUNTER_TEMP = 19) then --start computing second fork
						next_phase <= START_BC;
					else
						next_phase <= PAUSE;
					end if;
				when START_BC =>--start computing second fork
					next_phase <= ADD_BC;
				when ADD_BC =>
					if ((UPDATE = "1010110") and (COUNTER_TEMP = 19)) then -- stop adding branch constant
						next_phase <= CT0_COMPUTE;
					else
						next_phase <= ADD_BC;
					end if;
				when CT0_COMPUTE =>
					if ((UPDATE = "0110010") and (COUNTER_TEMP = 20)) then -- finished, read out CT0
						next_phase <= CT0_read_out;
					else
						next_phase <= CT0_COMPUTE;
					end if;
				when CT0_read_out =>
					if (reset = '1') then
							next_phase <= INIT_encr;
					elsif(counter_temp = 15) then
						next_phase <= rest;
					else
							next_phase <= CT0_read_out;
					end if;
				when others => next_phase <= REST;
			end case;
		end PROCESS;
	end generate;

	phase_change128288  : IF BS = BLOCK_SIZE_128  AND TS = TWEAKEY_SIZE_288 GENERATE
		process(phase,counter_temp,update,reset,one_CT)
			begin
			case(phase) is

				-- nothing happening

				WHEN REST =>
				if((reset = '1')) THEN
					if(decrypt = '0') then
						next_phase <= INIT_encr;
					else
						next_phase <= INIT_decr;
					end if;				else
					next_phase <= REST;
				end if;


				-----

				when INIT_decr =>
					if(counter_temp = 15) THEN
						next_phase <= UPDATING_KEY;
					else
						next_phase <= INIT_decr;
					end if;
				when UPDATING_KEY =>
					if ((UPDATE = "0000101")and (COUNTER_TEMP = 20)) then
						next_phase <= DECRYPTING;
					else
						next_phase <= UPDATING_KEY;
					end if;
				when DECRYPTING =>
					if(UPDATE = "0000001") and (counter_temp = 20) THEN
					NEXT_PHASE <= PT_READ_OUT;
				else
					NEXT_PHASE <= DECRYPTING;
				end if;
			when PT_READ_OUT =>
				next_phase <= PRE_FORK;

					---



				when INIT_encr =>
				if(counter_temp = 15) THEN
					next_phase <= PRE_FORK;
				else
					next_phase <= INIT_encr;
				end if;
				when PRE_FORK =>
				if ((UPDATE = "1011100") and (COUNTER_TEMP = 20)) then-- fork is reached
					next_phase <= FORK;
				else
					next_phase <= PRE_FORK;
				end if;
				when FORK =>
				if(counter_temp = 15) then
					next_phase <= CT1_COMPUTE;
				else
					next_phase <= FORK;
				end if;
				when CT1_COMPUTE =>
				if ((UPDATE = "0000101")and (COUNTER_TEMP = 20)) then --start pause to read out data CT1 + load forkstate into roundfunction
					next_phase <= CT1_read_out;
				else
					next_phase <= CT1_COMPUTE;
				end if;
				when CT1_read_out =>
				if(ONE_CT = '0') then
					if (COUNTER_TEMP = 15) then --start computing second fork
						next_phase <= PAUSE;
					else
						next_phase <= CT1_read_out;
					end if;
				else
					if (COUNTER_TEMP = 15) then
						next_phase <= rest;
					else
						next_phase <= CT1_read_out;
					end if;
				end if;
				when PAUSE =>
				if (COUNTER_TEMP = 19) then --start computing second fork
					next_phase <= START_BC;
				else
					next_phase <= PAUSE;
				end if;
				when START_BC => --start computing second fork
					next_phase <= ADD_BC;
				when ADD_BC =>
				if ((UPDATE = "0001011") and (COUNTER_TEMP = 19)) then -- stop adding branch constant
					next_phase <= CT0_COMPUTE;
				else
					next_phase <= ADD_BC;
				end if;
				when CT0_COMPUTE =>
				if ((UPDATE = "0100001") and (COUNTER_TEMP = 20)) then -- finished, read out CT0
					next_phase <= CT0_read_out;
				else
					next_phase <= CT0_COMPUTE;
				end if;
				when CT0_read_out =>
					if (reset = '1') then
							next_phase <= INIT_encr;
					elsif(counter_temp = 15) then
						next_phase <= rest;
					else
							next_phase <= CT0_read_out;
					end if;
				when others => next_phase <= REST;
			end case;
		end PROCESS;
	end generate;

	control_sig: process(phase) is
		begin
			retracing <= '0';
			no_clk_ke <= '0';
			UPDATING_KEY_SIGNAL <= '0';
				case(phase) is
					when rest         => no_clk_temp <= '1'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; fork_out <= '0';no_clk_rndcst<= '0'; read_in <= '0';
					when INIT_encr    => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; fork_out <= '0';no_clk_rndcst<= '0'; read_in <= '1';
					when INIT_decr    => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; fork_out <= '0';no_clk_rndcst<= '0'; read_in <= '1';
					when UPDATING_KEY => no_clk_temp <= '1'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; fork_out <= '0';no_clk_rndcst<= '0'; read_in <= '0'; UPDATING_KEY_SIGNAL <= '1';
					when DECRYPTING   => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; fork_out <= '0';no_clk_rndcst<= '0'; read_in <= '0'; retracing <= '1';
					when PT_READ_OUT  => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '1'; done1 <= '1'; FORK_OUT <= '0';no_clk_rndcst<= '0'; read_in <= '0';

					when PRE_FORK     => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '0'; read_in <= '0';
					when FORK         => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '1';no_clk_rndcst<= '0'; read_in <= '0';
					when CT1_COMPUTE  => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '0'; read_in <= '0';
					when CT1_read_out => no_clk_temp <= '1'; branch_cst_enable <= '0'; state_read <= '1'; done2 <= '0'; done1 <= '1'; FORK_OUT <= '0';no_clk_rndcst<= '1'; read_in <= '1'; no_clk_ke <= '1';
					when pause				=> no_clk_temp <= '1'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '1'; read_in <= '0';no_clk_ke <= '1';
					when START_BC			=> no_clk_temp <= '1'; branch_cst_enable <= '1'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '1'; read_in <= '0';
					when ADD_BC				=> no_clk_temp <= '0'; branch_cst_enable <= '1'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '0'; read_in <= '0';
					when CT0_COMPUTE  => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '0'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '0'; read_in <= '0';
					when CT0_read_out => no_clk_temp <= '0'; branch_cst_enable <= '0'; state_read <= '0'; done2 <= '1'; done1 <= '0'; FORK_OUT <= '0';no_clk_rndcst<= '0';read_in <= '0';
				end case;
	end process;

END Round;
