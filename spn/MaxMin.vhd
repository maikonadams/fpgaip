----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:08 11/11/2015 
-- Design Name: 
-- Module Name:    MaxMin - Behavioral 
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

entity MaxMin is
	 generic (width : integer := 8);
    Port ( in1 : in  STD_LOGIC_VECTOR ((width-1) downto 0);
           in2 : in  STD_LOGIC_VECTOR ((width-1) downto 0);
			  clock : in std_logic;
           max : out  STD_LOGIC_VECTOR ((width-1) downto 0);
           min : out  STD_LOGIC_VECTOR ((width-1) downto 0));
end MaxMin;

architecture Behavioral of MaxMin is

begin

comp: process(clock)
begin
if (clock'event and clock='1') then
	if in1 > in2 then
		max <= in1;
		min <= in2;
	else
		max <= in2;
		min <= in1;
	end if;
end if;
end process comp;


end Behavioral;

