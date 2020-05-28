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
package ForkSkinnyPKG is

	-- DEFINE BLOCKSIZE -----------------------------------------------------------
	TYPE BLOCK_SIZE IS (BLOCK_SIZE_64, BLOCK_SIZE_128);
	-------------------------------------------------------------------------------

	-- DEFINE TWEAKEYSIZE -----------------------------------------------------------
	TYPE TWEAKEY_SIZE IS (TWEAKEY_SIZE_192, TWEAKEY_SIZE_256, TWEAKEY_SIZE_288);
	-------------------------------------------------------------------------------

	--DEFINE FUNCTIONS ------------------------------------------------------------
	FUNCTION GET_WORD_SIZE  (BS : BLOCK_SIZE) RETURN INTEGER;
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAKEY_FACT (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAKEY_SIZE (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER;
	FUNCTION GET_FULL_TWEAKEY_SIZE (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER;
	FUNCTION GET_NUMBER_OF_ROUNDS (BS : BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER;
	FUNCTION GET_NONCE_SIZE (BS : BLOCK_SIZE; TS : TWEAKEY_SIZE; mode_saef : BOOLEAN) RETURN INTEGER;
	FUNCTION GET_COUNTER_SIZE (TS : TWEAKEY_SIZE) RETURN INTEGER;

	-------------------------------------------------------------------------------

end ForkSkinnyPKG;

package body ForkSkinnyPKG is

	-- FUNCTION: RETURN WORD SIZE -------------------------------------------------
	FUNCTION GET_WORD_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 4;
			ELSE
				RETURN 8;
			END IF;
	END GET_WORD_SIZE;
	-------------------------------------------------------------------------------

	-- FUNCTION: RETURN BLOCK SIZE ------------------------------------------------
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 64;
			ELSE
				RETURN 128;
			END IF;
	END GET_BLOCK_SIZE;
	-------------------------------------------------------------------------------
	FUNCTION GET_TWEAKEY_FACT (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER IS
	BEGIN
			IF    BS = BLOCK_SIZE_64 THEN
				RETURN 3;
			ELSIF TS = TWEAKEY_SIZE_288 THEN
				RETURN 3;
			ELSE
				RETURN 2;
			END IF;
	END GET_TWEAKEY_FACT;
	-- FUNCTION: RETURN TWEAK SIZE ------------------------------------------------
	FUNCTION GET_TWEAKEY_SIZE (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER IS
	BEGIN
			IF    ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_64)) THEN
				RETURN 192;
			ELSIF    ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_128)) THEN
				RETURN 192;
			ELSIF TS = TWEAKEY_SIZE_256 THEN
				RETURN 256;
			ELSE
				RETURN 320;
			END IF;
	END GET_TWEAKEY_SIZE;

	FUNCTION GET_FULL_TWEAKEY_SIZE (BS: BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER IS
	BEGIN
			IF    ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_64)) THEN
				RETURN 192;
			ELSIF    ((TS = TWEAKEY_SIZE_192) and (BS = BLOCK_SIZE_128)) THEN
				RETURN 256;
			ELSIF TS = TWEAKEY_SIZE_256 THEN
				RETURN 256;
			ELSE
				RETURN 384;
			END IF;
	END GET_FULL_TWEAKEY_SIZE;
	-------------------------------------------------------------------------------
	-- FUNCTION: RETURN NUMBER OF ROUNDS ------------------------------------------
	FUNCTION GET_NUMBER_OF_ROUNDS (BS : BLOCK_SIZE; TS : TWEAKEY_SIZE) RETURN INTEGER IS
	BEGIN
		IF    TS = TWEAKEY_SIZE_192 AND BS = BLOCK_SIZE_64 THEN
			RETURN 40;
		ELSIF TS = TWEAKEY_SIZE_192 AND BS = BLOCK_SIZE_128 THEN
			RETURN 48;
		ELSIF TS = TWEAKEY_SIZE_256 AND BS = BLOCK_SIZE_128 THEN
			RETURN 48;
		ELSE
			RETURN 56;
		END IF;
	END GET_NUMBER_OF_ROUNDS;
	-------------------------------------------------------------------------------
	-- FUNCTION: RETURN NONCE size in bits-----------------------------------------
	FUNCTION GET_NONCE_SIZE (BS : BLOCK_SIZE; TS : TWEAKEY_SIZE; mode_saef : BOOLEAN) RETURN INTEGER IS
	BEGIN
		IF mode_saef = false then
			IF    TS = TWEAKEY_SIZE_192 AND BS = BLOCK_SIZE_64 THEN
				RETURN 48;
			ELSIF TS = TWEAKEY_SIZE_192 AND BS = BLOCK_SIZE_128 THEN
				RETURN 48;
			ELSIF TS = TWEAKEY_SIZE_256 AND BS = BLOCK_SIZE_128 THEN
				RETURN 112;
			ELSE
				RETURN 104;
			END IF;
		else
			IF TS = TWEAKEY_SIZE_192 AND BS = BLOCK_SIZE_128 THEN
				RETURN 60;
			ELSIF TS = TWEAKEY_SIZE_256 AND BS = BLOCK_SIZE_128 THEN
				RETURN 124;
			end if;
		end if;
	END GET_NONCE_SIZE;

	FUNCTION GET_COUNTER_SIZE (TS : TWEAKEY_SIZE) RETURN INTEGER IS
	BEGIN
		IF TS = TWEAKEY_SIZE_288 then
				RETURN 53;
		else
			return 13;
		end if;
	END GET_COUNTER_SIZE;


end ForkSkinnyPKG;
