library IEEE; 
 use IEEE.STD_LOGIC_1164.ALL; 
 use ieee.std_logic_signed.all;


entity generateCarryAuto is 
	  generic (word_width : positive := 25; 
	           tk : positive := 12);
	  Port ( fromMult : in  STD_LOGIC_VECTOR (word_width -1 downto 0); 
	         carry : out  STD_LOGIC); 
end generateCarryAuto;

architecture Behavioral of generateCarryAuto is
signal residual: std_logic;
signal signbit: std_logic;
signal singOrRes: std_logic;
signal temp: std_logic_vector(tk -3 downto 0);

begin 

temp(0) <= fromMult(tk -2) or fromMult(tk -3);
gen_residual: for ii in 0 to tk -4 generate
	  temp(ii+1) <= temp(ii) or fromMult(tk -4 - ii);
end generate gen_residual;
residual <= temp(tk -3);

signbit <= not(fromMult(word_width -1));
singOrRes <= ((signbit) OR residual );
carry <= (fromMult(tk -1) AND singOrRes);

end Behavioral;
