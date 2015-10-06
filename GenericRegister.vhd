----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		11:45:10 09/30/2010 
-- Design Name: 	LabALU
-- Module Name:		GenericRegister - Structural 
-- Project Name:	LabALU
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A generic n-bit register with asynchronous clear.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package,
-- 					DFACE flip-flop entity.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.DFACE;

entity GenericRegister is
	generic (NUM_BITS: natural := 16);	-- Defaults to 16 bits
	port
	(
		-- Clock
		clk			: in	std_logic;
		
		-- Enables writing to register when asserted
		writeEnable	: in	std_logic;
		
		-- Sets register to zero when asserted
		clear		: in	std_logic;
		
		-- Input value bus (written to register on a clock edge, if enabled)
		D			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		
		-- Output value bus
		Q			: out	std_logic_vector((NUM_BITS - 1) downto 0)
	);
end GenericRegister;

architecture Structural of GenericRegister is
	
	-- No internal signals
	
begin
	
	-- Generate register storage
	RegisterStorage: for bitIndex in 0 to (NUM_BITS - 1) generate
	
		-- Instantiate a D flip-flop for each bit
		RegisterFF: DFACE
		port map
		(
			-- Appropriate bit of input bus connected to flip-flop input
			D => D(bitIndex),
			
			-- Register clocks all flip-flops concurrently
			C => clk,
			
			-- Write-enable controls flip-flops' clock-enable
			CE => writeEnable,
			
			-- Register clear clears all bits simultaneously
			CLR => clear,
			
			-- Flip-flop outputs form register output bus
			Q => Q(bitIndex)
		);
		
	end generate;
	
end Structural;
