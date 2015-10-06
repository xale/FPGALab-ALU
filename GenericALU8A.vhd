----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		11:04:35 10/01/2010 
-- Design Name:		LabALU
-- Module Name:		GenericALU8A - Structural 
-- Project Name:	LabALU
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Generic n-bit ALU, with the following eight modes:
--					000: A + B		(add)
--					001: A & B		(bitwise AND)
--					010: A | B		(bitwise OR)
--					011: A ^ B		(bitwise XOR)
--					100: A - B		(subtract)
--					101: A - B - 1	(subtract minus one; decrement)
--					110: A + B + 1	(add plus one; increment)
--					111: B			(pass-through)
--
-- Dependencies:	IEEE standard libraries, ALU8A_Cell entity.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity GenericALU8A is
	generic (NUM_BITS: natural := 8);	-- Defaults to 8 bits
	port
	(
		-- Input busses
		A			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		B			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		
		-- ALU mode selector bus
		mode		: in	std_logic_vector(2 downto 0);
		
		-- Output bus
		output		: out	std_logic_vector((NUM_BITS - 1) downto 0);
		
		-- Overflow flag
		overflow	: out	std_logic
	);
end GenericALU8A;

architecture Structural of GenericALU8A is
	
	-- ALU "cell" component declaration
	component ALU8A_Cell is
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
	
	-- Internal signals
	-- Carry values bus (note that this bus is one longer than the number of
	-- bits in the ALU, since there is carry in and out at the ends)
	signal carry	: std_logic_vector(NUM_BITS downto 0);
	
begin
	
	-- Generate ALU cell components for each bit in the ALU's width
	ALUCells: for bitIndex in 0 to (NUM_BITS - 1) generate
	
		ALUCell: ALU8A_Cell
		port map
		(
			-- Connect appropriate bit of input busses to cell inputs
			A => A(bitIndex),
			B => B(bitIndex),
			
			-- Connect same bit of carry bus to carry in
			carryIn => carry(bitIndex),
			
			-- Connect shared bus for mode control
			mode => mode,
			
			-- Connect cell output to output bus
			output => output(bitIndex),
			
			-- Connect carry out to next bit of carry bus
			carryOut => carry(bitIndex + 1)
		);
	
	end generate;
	
	-- First carry bit is set in some modes
	with mode select
		carry(0) <=	'1' when "100",
					'1' when "110",
					'0' when others;
	
	-- Connect XOR of carry into and carry out of MSB to overflow
	overflow <= (carry(NUM_BITS) xor carry(NUM_BITS - 1));
	
end Structural;
