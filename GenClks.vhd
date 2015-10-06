--clock generator for 424 class projects. 
--Produces 10Mhz and 16hz clocks.
library IEEE;
use IEEE.std_logic_1164.all;

entity GenClks is
 port (
 	clkext: 	in std_logic;	--50Mhz master clock 
  	reset: 		in std_logic;
	clk10m:		out std_logic;	--clk out at 10.0 Mhz
	clk16hz: 	out std_logic	--clk out at 16 hz
	  );
end GenClks;

architecture B_arch of GenClks is

signal mod5: std_logic_vector(5 downto 1);			
signal m5: std_logic;										--10 Mhz clk
signal lfsr16, sr_nxt: std_logic_vector(20 downto 1); 		--lfsr for 2^20 - 1
constant ST625K: std_logic_vector(20 downto 1):= X"9A632";  --state for 625_000 shifts
attribute init : string;
attribute init of mod5: signal is "00011";
attribute shreg_extract : string;				--Don't infer primitive SR's
attribute shreg_extract of mod5: signal is "no"; --To avoid reset problems with a rotating 1
attribute shreg_extract of lfsr16: signal is "no";
		
begin
------- Synthesize all clks from 50Mhz--------------------------
clk10m<= m5;		--10 Mhz clk pulse output. set for 40ns wide
m5<= mod5(5);
--UBUFG:bufg port map(I=>mod5(5), O=>m5);					
-----mod 5, S.R. divider chain running off 50Mhz----
P50M: process (clkext) is begin
if clkext'event and clkext='1' then
	mod5<= mod5(4 downto 1) & mod5(5);
end if;	
end process P50M;
----------------------------------------------------
-----16hz divider from 10mhz--------------
P10M: process (m5, reset, lfsr16) is begin
if reset='1' then
	lfsr16<= (others=>'0');
	clk16hz<= '0';
elsif rising_edge(m5) then	  --lfsr operates off m5
	-------------------***rollover with 0 decode gives 10mhz/(2^20-1) = 9.5 hz
	if lfsr16 = ST625K then  	--16hz reset for 10Mhz rate = 625_000 shifts.
		clk16hz<= '1';	 		
		lfsr16<=(others=>'0');			
	else
		clk16hz<= '0';
		lfsr16<= sr_nxt; 
	end if;
	----------------------------
end if;
sr_nxt<= lfsr16(19 downto 1) & (lfsr16(17) xnor lfsr16(20));
end process P10M;

-----------------------------------------------------
END B_arch;
