----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:02 11/11/2015 
-- Design Name: 
-- Module Name:    delayOneClk - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity delayOneClk is
	 generic (width : integer := 8);
    Port ( inz : in  STD_LOGIC_VECTOR ((width -1) downto 0);
			  clock : in std_logic;
           inz_1 : out  STD_LOGIC_VECTOR ((width -1) downto 0));
end delayOneClk;

architecture Behavioral of delayOneClk is
signal temp : std_logic_vector((width-1) downto 0 );
signal temp1 : std_logic_vector((width-1) downto 0 );
begin

delayCore : process (clock)
begin
	if clock'event and clock='1' then
		temp <= inz;
	end if;
end process delayCore;

inz_1 <= temp;

end Behavioral;

