library IEEE;
use IEEE.std_logic_1164.all;
entity fulladd is	  	-- single bit full adder cell by structure
  port (I1: in STD_LOGIC;
        I2: in STD_LOGIC;
        cin: in std_logic;		--carry in
        sum: out std_logic;
        cout: out std_logic  );
end fulladd;
architecture STRUCT_arch of fulladd is
begin
sum<= I1 XOR I2 XOR cin;
cout<= (I1 AND I2) OR (I1 AND cin) OR (I2 AND cin);
end STRUCT_arch;
