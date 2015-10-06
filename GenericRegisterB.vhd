----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:24:23 10/14/2010 
-- Design Name:		LabALU
-- Module Name:		GenericRegisterB - Behavioral 
-- Project Name:	LabALU
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		An alternate, behavioral description of a generic n-bit
--					register storage element.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.all;

entity GenericRegisterB	is
	generic (NUM_BITS	: natural	:= 16);	-- Defaults to 16 bits
	port
	(
		C	: in	std_logic;	-- Clock
		CE	: in	std_logic;	-- Clock enable (i.e., write-enable)
		CLR	: in	std_logic;	-- Clear
		
		-- Input bus
		D	: in	std_logic_vector((NUM_BITS - 1) downto 0);
		
		-- Output bus
		Q	: out	std_logic_vector((NUM_BITS - 1) downto 0)
	);
end GenericRegisterB;

architecture Behavioral of GenericRegisterB is
	
	-- Internal signals
	-- Internal value of Q
	signal Q_internal	: std_logic_vector((NUM_BITS - 1) downto 0);
	
	-- Value of output assigned on clock edge
	signal Q_next		: std_logic_vector((NUM_BITS - 1) downto 0);
	
begin
	
	-- Process for asynchronous-clear and rising-clock-edge events
	process(C, CLR)
	begin
		-- On a "clear" signal, zero the register
		if (CLR = AH_ON) then
			Q_internal <= (others => '0');
		-- On a rising clock edge, assign the next output value
		elsif rising_edge(C) then
			Q_internal <= Q_next;
		end if;
	end process;
	
	-- Output assignment logic (hold the current output unless the write-enable
	-- line is asserted, in which case overwrite with the current input value)
	Q_next <=	D when (CE = AH_ON) else
				Q_internal;
	
	-- Connect internal Q value to output
	Q <= Q_internal;
	
end Behavioral;
