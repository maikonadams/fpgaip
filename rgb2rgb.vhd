----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:49 05/23/2018 
-- Design Name: 
-- Module Name:    rgb2rgb - Behavioral 
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
use ieee.std_logic_signed.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rgb2rgb is
generic ( rgb_width : positive := 8
					);
    Port ( rr : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           gg : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           bb : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           rrout : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           ggout : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           bbout : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0));
end rgb2rgb;

architecture Behavioral of rgb2rgb is

component rgb2yuv 
generic ( rgb_width : positive := 8
					);
    Port ( rr : in  std_logic_vector (rgb_width -1 downto 0);
           gg : in  std_logic_vector (rgb_width -1 downto 0);
           bb : in  std_logic_vector (rgb_width -1 downto 0);
           yy : out std_logic_vector (rgb_width -1 downto 0);
           uu : out std_logic_vector (rgb_width -1 downto 0);
           vv : out std_logic_vector (rgb_width -1 downto 0));
end component;

component asyncRGB2YUV 
 generic ( rgb_width : positive := 8
					);
    Port ( rr : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           gg : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           bb : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           yy : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           vv : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           uu : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0));
end component;

component yuv2rgb 
generic ( rgb_width : positive := 8
					);
    Port ( yy : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           uu : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           vv : in  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           rr : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           gg : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0);
           bb : out  STD_LOGIC_VECTOR (rgb_width -1 downto 0));
end component;

signal tempr : std_logic_vector (rgb_width -1  downto 0);
signal tempg : std_logic_vector (rgb_width -1  downto 0);
signal tempb : std_logic_vector (rgb_width -1  downto 0);

begin

rgb2yuv_u : rgb2yuv generic map(rgb_width)
								 port map(rr,gg,bb, tempr, tempg, tempb);
								 
yuv2rgb_u : yuv2rgb generic map(rgb_width)
						  port map(tempr, tempg, tempb, rrout, ggout, bbout);

end Behavioral;

