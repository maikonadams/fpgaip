----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:05:47 05/23/2018 
-- Design Name: 
-- Module Name:    rgb2yuv - Behavioral 
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

entity rgb2yuv is
generic ( rgb_width : positive := 8
					);
    Port ( rr : in  std_logic_vector (rgb_width -1 downto 0);
           gg : in  std_logic_vector (rgb_width -1 downto 0);
           bb : in  std_logic_vector (rgb_width -1 downto 0);
           yy : out std_logic_vector (rgb_width -1 downto 0);
           uu : out std_logic_vector (rgb_width -1 downto 0);
           vv : out std_logic_vector (rgb_width -1 downto 0));
end rgb2yuv;

architecture Behavioral of rgb2yuv is

signal sr : signed(rgb_width downto 0);
signal sg : signed(rgb_width downto 0);
signal sb : signed(rgb_width downto 0);

signal g_plus : signed(rgb_width downto 0);
signal g_plus_div2 : signed(rgb_width -1 downto 0);

signal r_plus_b : signed(rgb_width downto 0);
signal r_plus_b_div2 : signed(rgb_width -1 downto 0);
signal rb2_minus_g : signed(rgb_width downto 0);

signal b_minus : signed(rgb_width  downto 0);
signal b_minus_div2 : signed(rgb_width -1 downto 0);

begin

--sr <= '0'&rr;
--sg <= '0'&gg;
--sb <= '0'&bb;

------------- G branch
g_plus <= signed('0'&r_plus_b_div2) + signed('0'&gg);
g_plus_div2 <= g_plus(rgb_width downto 1);
yy <= std_logic_vector(g_plus_div2);

------------- R branch
r_plus_b <= signed('0'&rr) + signed('0'&bb);
r_plus_b_div2 <= r_plus_b(rgb_width downto 1);
rb2_minus_g <= signed('0'&r_plus_b_div2) - signed('0'&gg);
uu <= std_logic_vector(rb2_minus_g(rgb_width downto 1));

------------- B branch
b_minus <= signed('0'&rr) - signed('0'&bb);
b_minus_div2 <= b_minus(rgb_width downto 1);
vv <= std_logic_vector(b_minus_div2);

end Behavioral;