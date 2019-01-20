library IEEE; 
 use IEEE.STD_LOGIC_1164.ALL; 
 use ieee.std_logic_signed.all;


entity multiplierFlex is 
	  generic (mult1_width : integer := 16; 
	         mult2_width : integer := 16; 
	         multOut_width : integer := 32);
	  Port ( mult1 : in  STD_LOGIC_VECTOR (mult1_width -1 downto 0); 
	       mult2 : in  STD_LOGIC_VECTOR (mult2_width -1 downto 0);
	       clock : in  STD_LOGIC; 
	       multOut : out  STD_LOGIC_VECTOR (multOut_width -1 downto 0)); 
end multiplierFlex;

architecture Behavioral of multiplierFlex is
begin 
multcoreU1: process(clock)
begin
if rising_edge(clock) then
	 multOut <= mult1 * mult2;
end if;
end process multcoreU1;

end Behavioral;
