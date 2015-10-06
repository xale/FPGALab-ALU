----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:01:52 09/30/2010 
-- Design Name:		LabALU
-- Module Name:		ALU8A_Cell - Structural 
-- Project Name:	LabALU
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A single-bit-slice component of an eight-function ALU.
--
-- Dependencies:	IEEE standard libraries, FPGALabDeclares package,
--					fulladd (full adder) component.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.FPGALabDeclares.fulladd;

entity ALU8A_Cell is
	port
	(
		-- Inputs
		A			: in	std_logic;
		B			: in	std_logic;
		
		-- Carry from previous bit
		carryIn		: in	std_logic;
		
		-- ALU mode selection bus
		mode		: in	std_logic_vector(2 downto 0);
		
		-- Output
		output		: out	std_logic;
		
		-- Carry to next bit
		carryOut	: out	std_logic
	);
end ALU8A_Cell;

architecture Structural of ALU8A_Cell is
	
	-- Internal signals
	-- Second input to full adder
	signal adderIn2	: std_logic;
	
	-- Output of full adder
	signal adderOut	: std_logic;
	
begin
	
	-- Instantiate full adder
	ADDER: fulladd
	port map
	(
		-- Connect ALU cell inputs to full adder inputs
		I1 => A,
		I2 => adderIn2,
		cin => carryIn,
		
		-- Connect output of adder to internal "sum" signal
		sum => adderOut,
		
		-- Connect carry out from adder directly to cell carry out signal (since
		-- this value is irrelevant in modes that don't use the adder, anyway)
		cout => carryOut
	);
	
	-- Second input to full adder is inverted in some circumstances
	with mode(2 downto 1) select
		adderIn2 <=	(not B)	when "10",
					(B)		when others;
	
	-- Output of cell depends on ALU mode
	with mode select
		output <=	(A and B)	when "001",		-- AND mode
					(A or B)	when "010",		-- OR mode
					(A xor B)	when "011",		-- XOR mode
					(B)			when "111",		-- Pass-through mode
					(adderOut)	when others;	-- Addition/subtraction modes
	
end Structural;

