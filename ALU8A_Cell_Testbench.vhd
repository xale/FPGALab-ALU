----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:57 09/30/2010 
-- Design Name:		LabALU
-- Module Name:		ALU8A_Cell_Testbench
-- Project Name:	LabALU
-- Target Devices:	N/A (Behavioral Simulation)	
-- Description:		Test bench for a single bit of an eight-function ALU.
--
-- Dependencies:	IEEE standard libraries, textio library, ALU8A_Cell entity.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;	-- File I/O

entity ALU8A_Cell_Testbench IS
end ALU8A_Cell_Testbench;

architecture model of ALU8A_Cell_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component ALU8A_Cell
	port
	(
		A			: in	std_logic;
		B			: in	std_logic;
		carryIn		: in	std_logic;
		mode		: in	std_logic_vector(2 downto 0);
		output		: out	std_logic;
		carryOut	: out	std_logic
	);
	end component;
	
	-- Inputs to UUT (w/ initial values)
	signal A		: std_logic := '0';
	signal B		: std_logic := '0';
	signal carryIn	: std_logic := '0';
	signal mode		: std_logic_vector(2 downto 0) := "000";
	
	-- Outputs read from UUT
	signal output	: std_logic;
	signal carryOut	: std_logic;
	
	-- Vectors containing input values to test
	constant NUM_VALUES			: integer := 8;
	constant A_VALUES			: std_logic_vector(0 to (NUM_VALUES - 1)) :=	('0', '1', '0', '1', '0', '1', '0', '1');
	constant B_VALUES			: std_logic_vector(0 to (NUM_VALUES - 1)) :=	('0', '0', '1', '1', '0', '0', '1', '1');
	constant CARRY_IN_VALUES	: std_logic_vector(0 to (NUM_VALUES - 1)) :=	('0', '0', '0', '0', '1', '1', '1', '1');
	
	-- Vector containing the different ALU modes to test
	constant NUM_MODES			: integer := 8;
	type MODE_VECTOR is array(natural range <>) of std_logic_vector(2 downto 0);
	constant MODE_VALUES		: MODE_VECTOR(0 to (NUM_MODES - 1)) :=	("000", "001", "010", "011", "100", "101", "110", "111");
	
	-- Results output file
	file resultsFile	: text open WRITE_MODE is "ALU8Cell Behavioral Simulation.txt";
	
begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	UUT: ALU8A_Cell
	port map
	(
		A => A,
		B => B,
		carryIn => carryIn,
		mode => mode,
		output => output,
		carryOut => carryOut
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
	write(lineBuffer, string'(" Time     | ALU Mode | A | B | Cin | Out | Cout"));
	writeline(resultsFile, lineBuffer);
	write(lineBuffer, string'("-----------------------------------------------"));
	writeline(resultsFile, lineBuffer);
	
	-- Loop over all ALU modes
	for modeIndex in 0 to (NUM_MODES - 1) loop
	
		-- Read next ALU mode from constant list
		mode <= MODE_VALUES(modeIndex);
	
		-- Loop over test inputs in 10ns steps
		for valueIndex in 0 to (NUM_VALUES - 1) loop
	
			-- Read next set of input values from constant list(s)
			A <= A_VALUES(valueIndex);
			B <= B_VALUES(valueIndex);
			carryIn <= CARRY_IN_VALUES(valueIndex);
			
			-- Pause to allow states to update
			wait for 10 ns;
			
			-- Write current simulation time and values to output file
			write(lineBuffer, string'(" "));
			write(lineBuffer, NOW, left, 9);
			write(lineBuffer, string'("| "));
			write(lineBuffer, to_bitvector(mode), left, 9);
			write(lineBuffer, string'("| "));
			write(lineBuffer, to_bit(A), left, 2);
			write(lineBuffer, string'("| "));
			write(lineBuffer, to_bit(B), left, 2);
			write(lineBuffer, string'("|  "));
			write(lineBuffer, to_bit(carryIn), left, 3);
			write(lineBuffer, string'("|  "));
			write(lineBuffer, to_bit(output), left, 3);
			write(lineBuffer, string'("|  "));
			write(lineBuffer, to_bit(carryOut));
			writeline(resultsFile, lineBuffer);
			
		end loop;
		
		-- Add a separator
		write(lineBuffer, string'("-----------------------------------------------"));
		writeline(resultsFile, lineBuffer);
		
	end loop;
	
	wait; -- will wait forever so process never repeats
	end process;

end model;
