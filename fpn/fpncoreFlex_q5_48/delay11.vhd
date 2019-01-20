-----------------------------------------------------------------
-----this code is auto-generated from a Matlab Script ---------- 
-------------  Maikon Nascimento 	12-Jun-2018------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity 	delay11 is 
	 generic (width_data : positive := 16);
	 Port ( clock : in  STD_LOGIC;
			 yin : in  STD_LOGIC_VECTOR ((width_data -1) downto 0);
			 ydelayed11 : out  STD_LOGIC_VECTOR ((width_data -1) downto 0));
end delay11;

architecture Behavioral of delay11	 is 

signal temp1 : std_logic_vector((width_data -1) downto 0 );
signal temp2 : std_logic_vector((width_data -1) downto 0 );
signal temp3 : std_logic_vector((width_data -1) downto 0 );
signal temp4 : std_logic_vector((width_data -1) downto 0 );
signal temp5 : std_logic_vector((width_data -1) downto 0 );
signal temp6 : std_logic_vector((width_data -1) downto 0 );
signal temp7 : std_logic_vector((width_data -1) downto 0 );
signal temp8 : std_logic_vector((width_data -1) downto 0 );
signal temp9 : std_logic_vector((width_data -1) downto 0 );
signal temp10 : std_logic_vector((width_data -1) downto 0 );
signal temp11 : std_logic_vector((width_data -1) downto 0 );

begin

delayCore : process (clock)
begin
if clock'event and clock='1' then
		 temp1<=yin;
		 temp2<=temp1;
		 temp3<=temp2;
		 temp4<=temp3;
		 temp5<=temp4;
		 temp6<=temp5;
		 temp7<=temp6;
		 temp8<=temp7;
		 temp9<=temp8;
		 temp10<=temp9;
		 temp11<=temp10;
end if;
end process delayCore;

ydelayed11<=temp11;

end Behavioral;
