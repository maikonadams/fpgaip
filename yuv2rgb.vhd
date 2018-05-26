----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:54:31 05/23/2018 
-- Design Name: 
-- Module Name:    yuv2rgb - Behavioral 
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
use ieee.numeric_std.all;
--use ieee.std_logic_signed.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity yuv2rgb is
generic ( rgb_width : positive := 8
					);
    Port ( yy : in  STD_LOGIC_VECTOR (rgb_width -1  downto 0);
           uu : in  STD_LOGIC_VECTOR (rgb_width -1  downto 0);
           vv : in  STD_LOGIC_VECTOR (rgb_width -1  downto 0);
           rr : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           gg : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           bb : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0));
end yuv2rgb;

architecture Behavioral of yuv2rgb is

signal y_minus_u : signed(rgb_width downto 0);
signal y_plus_u : signed(rgb_width downto 0);
signal yu_plus_v : signed(rgb_width downto 0);

begin
-- Green branch
y_minus_u <= signed('0'&yy) - signed(uu);
gg <= std_logic_vector(y_minus_u(rgb_width -1 downto 0));

-- Red branch
y_plus_u <= signed('0'&yy) + signed(uu);
yu_plus_v <= y_plus_u + signed(vv);
rr <= std_logic_vector(yu_plus_v(rgb_width -1 downto 0));

-- Blue branch
bb <= std_logic_vector(y_plus_u(rgb_width -1 downto 0) - signed(vv));

end Behavioral;

