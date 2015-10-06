----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		14:32 10/01/2010 
-- Design Name:		LabALU
-- Module Name:		GenericALU8A_Testbench
-- Project Name:	LabALU
-- Target Devices:	N/A (Behavioral Simulation)	
-- Description:		Test bench for an n-bit eight-function ALU.
--
-- Dependencies:	IEEE standard libraries, textio library, GenericALU8A entity.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;	-- File I/O

entity GenericALU8A_Testbench is
end GenericALU8A_Testbench;

architecture model of GenericALU8A_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component GenericALU8A
	--generic (NUM_BITS: natural := 8);
	port
	(
	--	A			: in	std_logic_vector((NUM_BITS - 1) downto 0);
	--	B			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		A			: in	std_logic_vector(7 downto 0);
		B			: in	std_logic_vector(7 downto 0);
		mode		: in	std_logic_vector(2 downto 0);
	--	output		: out	std_logic_vector((NUM_BITS - 1) downto 0);
		output		: out	std_logic_vector(7 downto 0);
		overflow	: out	std_logic
	);
	end component;
	
	-- Generic component size
	constant BUS_WIDTH	: integer := 8;
	
	-- Inputs to UUT (w/ initial values)
	signal A		: std_logic_vector((BUS_WIDTH - 1) downto 0) := (others => '0');
	signal B		: std_logic_vector((BUS_WIDTH - 1) downto 0) := (others => '0');
	signal mode		: std_logic_vector(2 downto 0) := "000";
	
	-- Outputs read from UUT
	signal output	: std_logic_vector((BUS_WIDTH - 1) downto 0);
	signal overflow	: std_logic;
	
	-- Vectors containing input values to test
	constant NUM_VALUES			: integer := 16;
	type BUS_VECTOR is array(natural range <>) of std_logic_vector((BUS_WIDTH - 1) downto 0);
	constant A_VALUES			: BUS_VECTOR(0 to (NUM_VALUES - 1)) := ("00000000", "00000001", "00000000", "00000001", "11111111", "00000000", "11111111", "01111111", "00000000", "01111111", "00000001", "01111111", "10000000", "10000000", "01001001", "00110011");
	constant B_VALUES			: BUS_VECTOR(0 to (NUM_VALUES - 1)) := ("00000000", "00000000", "00000001", "00000001", "00000000", "11111111", "11111111", "00000000", "01111111", "00000001", "01111111", "01111111", "00000001", "11111111", "00011001", "11001101");
	
	-- Vector containing the different ALU modes to test
	constant NUM_MODES			: integer := 8;
	type MODE_VECTOR is array(natural range <>) of std_logic_vector(2 downto 0);
	constant MODE_VALUES		: MODE_VECTOR(0 to (NUM_MODES - 1)) :=	("000", "001", "010", "011", "100", "101", "110", "111");
	
	-- Results output file
	-- Human-readable
	--file resultsFile	: text open WRITE_MODE is "GenericALU8A Behavioral Simulation.txt";
	
	-- CSV
	--file resultsFile	: text open WRITE_MODE is "GenericALU8A Behavioral Simulation.csv";

begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	UUT: GenericALU8A
	--generic map(NUM_BITS => BUS_WIDTH)
	port map
	(
		A => A,
		B => B,
		mode => mode,
		output => output,
		overflow => overflow
	);

tb : process -- Main model process

	-- Process-local variables
	variable modeIndex	: integer := 0;
	variable valueIndex	: integer := 0;
	variable lineBuffer	: LINE;

begin
	-- Allow time for global reset
	wait for 100 ns;
	
	-- Create column headers in results output file
	-- Human-readable
	--write(lineBuffer, string'(" Time   | ALU Mode | A    | B    | Out  | Overflow"));
	--writeline(resultsFile, lineBuffer);
	--write(lineBuffer, string'("--------------------------------------------------"));
	--writeline(resultsFile, lineBuffer);
	
	-- CSV
	--write(lineBuffer, string'("Time,ALU Mode,Input A,Input B,Output,Overflow"));
	--writeline(resultsFile, lineBuffer);
	
	-- Loop over all ALU modes
	for modeIndex in 0 to (NUM_MODES - 1) loop
	
		-- Read next ALU mode from constant list
		mode <= MODE_VALUES(modeIndex);
	
		-- Loop over test inputs in 10ns steps
		for valueIndex in 0 to (NUM_VALUES - 1) loop
	
			-- Read next set of input values from constant list(s)
			A <= A_VALUES(valueIndex);
			B <= B_VALUES(valueIndex);
			
			-- Pause to allow states to update
			wait for 10 ns;
			
			-- Write current simulation time and values to output file
			-- Human-readable
			--write(lineBuffer, string'(" "));
			--write(lineBuffer, NOW, left, 7);
			--write(lineBuffer, string'("| "));
			--write(lineBuffer, to_bitvector(mode), left, 9);
			--write(lineBuffer, string'("| "));
			--write(lineBuffer, to_integer(signed(A)), left, 5);
			--write(lineBuffer, string'("| "));
			--write(lineBuffer, to_integer(signed(B)), left, 5);
			--write(lineBuffer, string'("| "));
			--write(lineBuffer, to_integer(signed(output)), left, 5);
			--write(lineBuffer, string'("| "));
			--write(lineBuffer, to_bit(overflow));
			--writeline(resultsFile, lineBuffer);
			
			-- CSV
			--write(lineBuffer, NOW);
			--write(lineBuffer, string'(","));
			--write(lineBuffer, to_bitvector(mode));
			--write(lineBuffer, string'(","));
			--write(lineBuffer, to_integer(signed(A)));
			--write(lineBuffer, string'(","));
			--write(lineBuffer, to_integer(signed(B)));
			--write(lineBuffer, string'(","));
			--write(lineBuffer, to_integer(signed(output)));
			--write(lineBuffer, string'(","));
			--write(lineBuffer, to_bit(overflow));
			--writeline(resultsFile, lineBuffer);
			
		end loop;
		
		-- Add a separator (human-readable only)
		--write(lineBuffer, string'("--------------------------------------------------"));
		--writeline(resultsFile, lineBuffer);
		
	end loop;
	
	wait; -- will wait forever so process never repeats
	end process;

end model;
