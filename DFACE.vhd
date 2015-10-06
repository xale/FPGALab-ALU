----------------------------------------------------------------------------------
-- Company:		JHU ECE
-- Engineer:	Alex Heinz
-- 
-- Create Date:		14:20:39 09/11/2010 
-- Design Name:		Lab 2A
-- Module Name:		DFACE - Main_Arch 
-- Project Name:		Lab 2A
-- Target Devices:	XILINX Spartan3 XC3S1000
-- Tool versions:		
-- Description:		A D flip-flop with asynchronous reset and clock-enable.
--
-- Dependencies:		IEEE standard libraries, AHeinzDeclaresPackage.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.all;

entity DFACE is
	port
	(
		D		: in	std_logic;	-- Data input
		C		: in	std_logic;	-- Clock input
		CE		: in	std_logic;	-- Asynchronous clock-enable (active-high)
		CLR	: in	std_logic;	-- Asynchronous reset (active-high)
		Q		: out	std_logic	-- Data output
	);
end DFACE;

architecture Main_Arch of DFACE is
	-- No internal signals
begin
	
	-- Process for reset and rising-clock-edge events
	process(C, CLR)
	begin
		-- On a "reset" signal:
		if (CLR = AH_ON) then
			-- Clear output value
			Q <= '0';
		-- On a rising clock edge:
		elsif (rising_edge(C)) then
			-- If the clock enable is asserted, store the current input value
			if (CE = AH_ON) then
				-- Assign input to stored value
				Q <= D;
			end if;
		end if;
	end process;
	
end Main_Arch;

