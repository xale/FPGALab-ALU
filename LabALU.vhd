----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		16:18:53 10/08/2010 
-- Design Name:		LabALU
-- Module Name:		LabALU - Structural 
-- Project Name:	LabALU
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Top-level entity for ALU testing via PC-JTAG bridge.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares library,
--					FPGALabDeclares library, GenericALU8A entity,
--					GenericRegister entity, GenClks entity, JTAG_IFC entity
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.FPGALabDeclares.GenClks;
use WORK.FPGALabDeclares.JTAG_IFC;
use WORK.AHeinzDeclares.all;

entity LabALU is
	port
	(
		-- 50MHz board clock
		clk50	: in	std_logic;
		
		-- "Input latch" button
		sw1		: in	std_logic;
		
		-- Reset button
		swrst	: in	std_logic;
		
		-- LED digits
		ls		: out	std_logic_vector(6 downto 0);
		rs		: out	std_logic_vector(6 downto 0);
		
		-- Decimal point for overflow indicator
		lsdp	: out	std_logic;
		
		-- Flash-memory controller enable/disable line
		fceb	: out	std_logic
	);
end LabALU;

architecture Structural of LabALU is
	
	-- Define ALU bus width
	constant ALU_BUS_WIDTH 		: integer	:= 8;
	constant ALU_MODE_BUS_WIDTH	: integer	:= 3;
	
	-- Internal signals
	-- 10MHz internal clock
	signal clk10MHz		: std_logic;
	
	-- Inverted (active-high) pushbutton input
	signal sw1_inv		: std_logic;
	
	-- Inverted (active-high) reset signal
	signal swrst_inv	: std_logic;
	
	-- 64-bit JTAG interface busses
	signal dataFromPC	: std_logic_vector(63 downto 0);
	signal dataToPC		: std_logic_vector(63 downto 0);
	
	-- JTAG interface aliases for register inputs
	alias regAInput		: std_logic_vector((ALU_BUS_WIDTH - 1) downto 0) is
		dataFromPC((ALU_BUS_WIDTH - 1) downto 0);
	alias regBInput		: std_logic_vector((ALU_BUS_WIDTH - 1) downto 0) is
		dataFromPC(((ALU_BUS_WIDTH - 1) + ALU_BUS_WIDTH) downto ALU_BUS_WIDTH);
	alias modeRegInput	: std_logic_vector((ALU_MODE_BUS_WIDTH - 1) downto 0) is
		dataFromPC(((ALU_MODE_BUS_WIDTH - 1) + (ALU_BUS_WIDTH * 2)) downto (ALU_BUS_WIDTH * 2));
	
	-- Eight-bit register output/ALU input busses
	signal ALUInputA	: std_logic_vector((ALU_BUS_WIDTH - 1) downto 0);
	signal ALUInputB	: std_logic_vector((ALU_BUS_WIDTH - 1) downto 0);
	
	-- Three-bit ALU mode input bus
	signal ALUModeInput	: std_logic_vector((ALU_MODE_BUS_WIDTH - 1) downto 0);
	
	-- JTAG interface alias for ALU output bus
	alias ALUOutput		: std_logic_vector((ALU_BUS_WIDTH - 1) downto 0) is
		DataToPC((ALU_BUS_WIDTH - 1) downto 0);
	
	-- JTAG interface alias for ALU overflow output line
	alias ALUOverflow	: std_logic is DataToPC(ALU_BUS_WIDTH);
	
	-- Additional aliases for ALU output to LED digits
	alias LEDHighNibble	: std_logic_vector(3 downto 0) is
		dataToPC((ALU_BUS_WIDTH - 1) downto (ALU_BUS_WIDTH / 2));
	alias LEDLowNibble	: std_logic_vector(3 downto 0) is
		dataToPC(((ALU_BUS_WIDTH / 2) - 1) downto 0);
	
begin
	
	-- Disable flash memory
	fceb <= AL_OFF;
	
	-- Invert input and reset buttons
	sw1_inv <= NOT sw1;
	swrst_inv <= NOT swrst;
	
	-- Instantiate clock divider
	ClkSource: GenClks
	port map
	(
		-- Connect built-in 50MHz clock to generator input clock 
		clkext => clk50,
		
		-- Connect inverted global reset to generator reset
		reset => swrst_inv,
		
		-- Leave output 16Hz clock disconnected
		clk16hz => open,
		
		-- Connect output 10MHz clock to local clock line
		clk10m => clk10MHz
	);
	
	-- Instantiate JTAG bridge entity
	PCInterface: JTAG_IFC
	port map
	(
		-- Ignore debug bus
		bscan => open,
		
		-- Connect input and output busses
		dat_to_pc => DataToPC,
		dat_from_pc => DataFromPC
	);
	
	-- Instantiate ALU input registers
	-- Input register A
	InputRegA: GenericRegister
	generic map(NUM_BITS => ALU_BUS_WIDTH)
	port map
	(
		-- Connect internal clock to register clock
		clk => clk10MHz,
		
		-- Connect input pushbutton to register enable
		writeEnable => sw1_inv,
		
		-- Connect reset button to register clear
		clear => swrst_inv,
		
		-- Connect input from JTAG, output to ALU
		D => RegAInput,
		Q => ALUInputA
	);
	
	-- Input register B
	InputRegB: GenericRegister
	generic map(NUM_BITS => ALU_BUS_WIDTH)
	port map
	(
		-- Connect internal clock to register clock
		clk => clk10MHz,
		
		-- Connect input pushbutton to register enable
		writeEnable => sw1_inv,
		
		-- Connect reset button to register clear
		clear => swrst_inv,
		
		-- Connect input from JTAG, output to ALU
		D => RegBInput,
		Q => ALUInputB
	);
	
	-- Instantiate ALU mode register
	ModeReg: GenericRegister
	generic map(NUM_BITS => ALU_MODE_BUS_WIDTH)
	port map
	(
		-- Connect internal clock to register clock
		clk => clk10MHz,
		
		-- Register-enable tied high
		writeEnable => AH_ON,
		
		-- Connect reset button to register clear
		clear => swrst_inv,
		
		-- Connect input from JTAG, output to ALU
		D => ModeRegInput,
		Q => ALUModeInput
	);
	
	-- Instantiate ALU
	ALU: GenericALU8A
	generic map(NUM_BITS => ALU_BUS_WIDTH)
	port map
	(
		-- Connect input registers to ALU inputs
		A => ALUInputA,
		B => ALUInputB,
		
		-- Connect mode register output to ALU mode bus
		mode => ALUModeInput,
		
		-- Connect ALU output to output bus
		output => ALUOutput,
		
		-- Connect ALU overflow to overflow line
		overflow => ALUOverflow
	);
	
	-- Convert ALU output byte to hex digits, and connect to LEDs
	ls <= NibbleToHexDigit(LEDHighNibble);
	rs <= NibbleToHexDigit(LEDLowNibble);
	
	-- Connect overflow line to left LED decimal point
	lsdp <= ALUOverflow;
	
end Structural;
