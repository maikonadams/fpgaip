-----------------------------------------------------------------
-----this code is auto-generated from a Matlab Script ---------- 
-------------  Maikon Nascimento 	12-Jun-2018------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity 	delay2 is 
	 generic (width_data : positive := 16);
	 Port ( clock : in  STD_LOGIC;
			 yin : in  STD_LOGIC_VECTOR ((width_data -1) downto 0);
			 ydelayed2 : out  STD_LOGIC_VECTOR ((width_data -1) downto 0));
end delay2;

architecture Behavioral of delay2	 is 

signal temp1 : std_logic_vector((width_data -1) downto 0 );
signal temp2 : std_logic_vector((width_data -1) downto 0 );

begin

delayCore : process (clock)
begin
if clock'event and clock='1' then
		 temp1<=yin;
		 temp2<=temp1;
end if;
end process delayCore;

ydelayed2<=temp2;

end Behavioral;
