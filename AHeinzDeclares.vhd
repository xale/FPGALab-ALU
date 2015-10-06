----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:00 09/21/2010 
-- Module Name:		AHeinzDeclares 	
-- Description:		Standard portable "useful stuff" package.
--
-- Dependencies:	IEEE standard libraries
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AHeinzDeclares is

	-- Constants
	constant AH_ON	: std_logic := '1';	-- Active High "On"
	constant AH_OFF	: std_logic := '0';	-- Active High "Off"
	constant AL_ON	: std_logic := '0';	-- Active Low "On"
	constant AL_OFF	: std_logic := '1';	-- Active Low "Off"

----------------------------------------------------------------------------------

	-- Types
	-- ROM for storing seven-bit binary-coded digit values
	type DigitROM is array(natural range <>) of std_logic_vector(6 downto 0);
	
----------------------------------------------------------------------------------
	
	-- Functions
	-- Four-bit nibble to seven-bit binary-coded-hexadecimal
	-- (used to display to the LED digits on the board)
	function NibbleToHexDigit(nibble : std_logic_vector(3 downto 0))
		return std_logic_vector;

----------------------------------------------------------------------------------
	
	-- Components
	-- D flip-flop
	component DFACE
	port
	(
		D	: in	std_logic;	-- Data input
		C	: in	std_logic;	-- Clock input
		CE	: in	std_logic;	-- Asynchronous clock-enable
		CLR	: in	std_logic;	-- Asynchronous reset
		Q	: out	std_logic	-- Data output
	);
	end component;
	
	-- One-bit toggle latch
	component Toggle1
	port
	(
		S_AL	: in	std_logic;	-- Value-toggle input (active low)
		RESET	: in	std_logic;	-- Reset signal
		Q		: out	std_logic	-- Latched value
	);
	end component;
	
	-- Generic n-bit register
	component GenericRegister is
	generic (NUM_BITS: natural := 16);	-- Defaults to 16 bits
	port
	(
		clk			: in	std_logic;	-- Clock
		writeEnable	: in	std_logic;	-- Input enable
		clear		: in	std_logic;	-- Clear (zeros register)
		D			: in	std_logic_vector((NUM_BITS - 1) downto 0);	-- Input
		Q			: out	std_logic_vector((NUM_BITS - 1) downto 0)	-- Output
	);
	end component;
	
	-- Generic n-bit eight-function ALU
	component GenericALU8A is
	generic (NUM_BITS: natural := 8);	-- Defaults to 8 bits
	port
	(
		A			: in	std_logic_vector((NUM_BITS - 1) downto 0);	-- Inputs
		B			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		mode		: in	std_logic_vector(2 downto 0);	-- Mode selection bus
		output		: out	std_logic_vector((NUM_BITS - 1) downto 0);	-- Output
		overflow	: out	std_logic						-- Overflow flag
	);
	end component;
	
end package AHeinzDeclares;

package body AHeinzDeclares is

	-- Function definitions
	function NibbleToHexDigit(nibble : std_logic_vector(3 downto 0))
		return std_logic_vector
	is
		
		-- Define lookup table for digit values
		constant DigitLUT: DigitROM(0 to 15) :=
		(
			"1110111", "0010010", "1011101", "1011011",	-- 0, 1, 2, 3,
			"0111010", "1101011", "1101111", "1010010",	-- 4, 5, 6, 7,
			"1111111", "1111011", "1111110", "0101111",	-- 8, 9, A, B,
			"1100101", "0011111", "1101101", "1101100"	-- C, D, E, F
		);
		
	begin
		
		-- Convert input nibble to index in lookup table, return the bus signal
		-- for the appropriate digit to display
		return DigitLUT(TO_INTEGER(unsigned(nibble)));
		
	end NibbleToHexDigit;
	
end package body AHeinzDeclares;
