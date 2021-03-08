-----------------------------------------------------------------------------
-- Title      : FPGA TDC
-- Copyright © 2015 Harald Homulle / Edoardo Charbon
-----------------------------------------------------------------------------
-- This file is part of FPGA TDC.

-- FPGA TDC is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- FPGA TDC is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with FPGA TDC.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------
-- File       : tdc_library.vhd
-- Author     : <h.a.r.homulle@tudelft.nl>
-- Company    : TU Delft
-- Last update: 2015-01-01
-- Platform   : FPGA (tested on Spartan 6)
-----------------------------------------------------------------------------
-- Description: 
-- Libary  containing the TDC components
-----------------------------------------------------------------------------
-- Revisions  :
-- Date			Version		Author		Description
-- 2014  		1.0      	Homulle		TDC library
-----------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE tdc_library IS

	FUNCTION count_ones(s : std_logic_vector) RETURN INTEGER IS
		VARIABLE temp : INTEGER := 0;

	BEGIN
		FOR i IN s'range LOOP
			IF s(i) = '1' THEN 
				temp := temp + 1; 
			END IF;
		END LOOP;
  
		RETURN temp;
	END FUNCTION;

	COMPONENT fine_tdc_with_encoder IS
		GENERIC (
			STAGES		: INTEGER;
			FINE_BITS	: INTEGER;
			Xoff		: INTEGER;
			Yoff		: INTEGER);
		PORT (
			clock 			: IN  std_logic;
			reset 			: IN  std_logic;
			hit 			: IN  std_logic;
			value_fine		: OUT std_logic_vector((FINE_BITS-1) DOWNTO 0));
	END COMPONENT;

	COMPONENT fine_tdc IS
		GENERIC (
			STAGES 	: INTEGER;
			Xoff	: INTEGER;
			Yoff	: INTEGER);
		PORT (
			trigger				: IN std_logic;
			reset				: IN std_logic;
			clock				: IN std_logic;
			latched_output    	: OUT std_logic_vector(STAGES-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT therm2bin_pipeline_count IS
		GENERIC (
			b 		: INTEGER);
		PORT (
			clock   : IN  std_logic;
			reset 	: IN  std_logic;
			valid 	: IN  std_logic;
			thermo  : IN  std_logic_vector(((2**b)-1) DOWNTO 0);
			bin     : OUT std_logic_vector((b-1) DOWNTO 0));
	END COMPONENT;
	
	COMPONENT mux_latch IS
		PORT (
			reset			: IN std_logic;
			clock			: IN std_logic;	
			in_A			: IN std_logic;	
			in_B			: IN std_logic;	
			sel				: IN std_logic;	
			mux_out			: OUT std_logic);
	END COMPONENT;
	
	COMPONENT clock_dcm IS
		PORT (
			clk					: IN std_logic;
			reset				: IN std_logic;
			clock_200MHz		: OUT std_logic;
			clock_200MHz_inv	: OUT std_logic);
	END COMPONENT;
	
END tdc_library;
