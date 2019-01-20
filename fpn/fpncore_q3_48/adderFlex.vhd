library IEEE; 
 use IEEE.STD_LOGIC_1164.ALL; 
 use ieee.std_logic_signed.all;


entity adderFlex2 is 
	  generic (adder1_width : integer := 9; 
	         adder2_width : integer := 11; 
	         sum_width : integer := 11);
	  Port ( adder1in : in  STD_LOGIC_VECTOR (adder1_width -1 downto 0); 
	       adder2in : in  STD_LOGIC_VECTOR (adder2_width -1 downto 0);
	       clock : in  STD_LOGIC; 
	       sum : out  STD_LOGIC_VECTOR (sum_width -1 downto 0)); 
end adderFlex2;

architecture Behavioral of adderFlex2 is
begin 
addcoreU1: process(clock)
begin
if rising_edge(clock) then
	 sum <= adder1in + adder2in;
end if;
end process;

end Behavioral;
