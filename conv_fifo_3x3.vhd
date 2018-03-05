----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:00:52 03/04/2018 
-- Design Name: 
-- Module Name:    conv_fifo_3x3 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity conv_fifo_3x3 is
	generic(DATA_WIDTH : positive := 3);
    Port ( pixel_stream : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
           clock : in  STD_LOGIC; 
           conv_pixel : out  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0));
end conv_fifo_3x3;

architecture Behavioral of conv_fifo_3x3 is

-- HAS to be the multiplication size , size based on 7*4 which is the max number for this case
signal outshift9 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift8 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift7 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift6 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift5 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift4 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift3 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift2 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);
signal outshift1 : STD_LOGIC_VECTOR (DATA_WIDTH +1  downto 0);

signal fifo9 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo8 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo7 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo6 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo5 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo4 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo3 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo2 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal fifo1 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);

signal temp5 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp4 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp3 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp2 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp1 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);

signal temp52 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp42 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp32 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp22 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
signal temp12 : STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);

signal accumulation : STD_LOGIC_VECTOR (DATA_WIDTH +4 downto 0);
signal divBy16 : STD_LOGIC_VECTOR (DATA_WIDTH downto 0);

begin

--fifo9 <= pixel_stream;

fifo:process(clock)
begin
	if rising_edge(clock) then
		fifo9 <= pixel_stream;
		fifo8 <= fifo9;
		fifo7 <= fifo8;
		temp1 <= fifo7;
		temp2 <= temp1;
		temp3 <= temp2;
		temp4 <= temp3;
		temp5 <= temp4;
		fifo6 <= temp5;
		fifo5 <= fifo6;
		fifo4 <= fifo5;
		temp12 <= fifo4;
		temp22 <= temp12;
		temp32 <= temp22;
		temp42 <= temp32;
		temp52 <= temp42;
		fifo3 <= temp52;
		fifo2 <= fifo3;
		fifo1 <= fifo2;
	end if;
end process fifo;

-- bit shifting to realize multiplication x2
outshift8 <= '0'&fifo8(DATA_WIDTH -1 downto 0)&'0';
outshift6 <= '0'&fifo6(DATA_WIDTH -1 downto 0)&'0';
outshift4 <= '0'&fifo4(DATA_WIDTH -1 downto 0)&'0';
outshift2 <= '0'&fifo2(DATA_WIDTH -1 downto 0)&'0';

-- bit shifting to realize multiplication x4
outshift5 <= fifo5(DATA_WIDTH -1 downto 0)&"00";

-- no bit shifting x1
outshift1 <= "00"&fifo1;
outshift3 <= "00"&fifo3;
outshift7 <= "00"&fifo7;
outshift9 <= "00"&fifo9;

-- accumulation
accumulation <= ("000"&outshift1) + ("000"&outshift2) + ("000"&outshift3) + ("000"&outshift4) + ("000"&outshift5) +
				    ("000"&outshift6) + ("000"&outshift7) + ("000"&outshift8) + ("000"&outshift9);
				  
-- division by 16
divBy16 <= accumulation(DATA_WIDTH +4 downto 4);

-- cropping the final result
conv_pixel <= divBy16(DATA_WIDTH -1 downto 0);


end Behavioral;

