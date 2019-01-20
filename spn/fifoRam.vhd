----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:18:10 10/13/2017 
-- Design Name: 
-- Module Name:    fifoRam - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifoRam is
generic( constant data_width : positive := 16;
				constant fifo_depth : positive := 3840 -- 8x8 and 8*2 ... memory is from 0 .. to 16= 17elements
	);
    Port ( yin : in  STD_LOGIC_VECTOR (data_width -1 downto 0);
           clock : in  STD_LOGIC;
           yij : out  STD_LOGIC_VECTOR (data_width -1 downto 0);
           yi_1jp1 : out  STD_LOGIC_VECTOR (data_width -1 downto 0);
           yi_1j : out  STD_LOGIC_VECTOR (data_width -1 downto 0);
           yi_1j_1 : out  STD_LOGIC_VECTOR (data_width -1 downto 0);
           yi_2j : out  STD_LOGIC_VECTOR (data_width -1 downto 0));
end fifoRam;

architecture Behavioral of fifoRam is

type FIFO_wRAM is array(0 to (fifo_depth/2 -1) ) of std_logic_vector(data_width -1 downto 0);
signal fifo_inst_i_1_jp1 : FIFO_wRAM;
signal fifo_inst_i_2j : FIFO_wRAM;

attribute ram_style: string;

attribute ram_style of fifo_inst_i_1_jp1 : signal is "block";
attribute ram_style of fifo_inst_i_2j : signal is "block";

constant ADDR_LIM : integer := (fifo_depth/2 -1); --3
--signal addr_w : integer range 0 to (ADDR_LIM ):= 0;
--signal addr_r : integer range 0 to (ADDR_LIM ):= 1;
signal addr_w : std_logic_vector(15 downto 0);
signal addr_r : std_logic_vector(15 downto 0);

signal s_yij : STD_LOGIC_VECTOR (data_width -1 downto 0);
signal s_yi_1jp1 : STD_LOGIC_VECTOR (data_width -1 downto 0);
signal s_yi_2j : STD_LOGIC_VECTOR (data_width -1 downto 0);

signal temp_i_1j : STD_LOGIC_VECTOR (data_width -1 downto 0);
signal temp_i_1j_1 : STD_LOGIC_VECTOR (data_width -1 downto 0);

begin
--yij <= yin;

-- update address
update_address: process(clock)
begin
	if(rising_edge(clock)) then
		if addr_w < (ADDR_LIM -1) then --2
			addr_w <= addr_w + '1';
			--addr_r <= addr_r + '1';
			--if addr_r = "0000000000000010" then  --2
			if addr_r = (ADDR_LIM -1) then  --2
				addr_r <= "0000000000000000";
			else
				addr_r <= addr_r + '1';
			end if;
		else
			addr_w <= "0000000000000000";
			addr_r <= "0000000000000001";
		end if;
	end if;
end process update_address;

-- first assigning 
yij_U:process(clock)
begin
	if (rising_edge(clock)) then
		s_yij <= yin;
	end if;
end process yij_U;
yij <= s_yij;

-- FIFO i_1_jp1
i_1_jp1: PROCESS(clock)
BEGIN
    if(rising_edge(clock)) then
       -- if(we='1') then
				--fifo_inst_i_1_jp1(to_integer(unsigned(addr_w))) <= yin;
				fifo_inst_i_1_jp1(to_integer(unsigned(addr_w))) <= s_yij;
       -- end if;
        s_yi_1jp1 <= fifo_inst_i_1_jp1(to_integer(unsigned(addr_r)));
    end if;
END PROCESS i_1_jp1;
yi_1jp1 <= s_yi_1jp1;

--FIFO i_1j
i_1j: process(clock)
begin
	if (rising_edge(clock)) then
		temp_i_1j <= s_yi_1jp1;
	end if;
end process i_1j;
yi_1j <= temp_i_1j;

--FIFO i_1j_1 temp_i_1j_1
i_1j_1: process(clock)
begin
	if (rising_edge(clock)) then
		temp_i_1j_1 <= temp_i_1j;
	end if;
end process i_1j_1;
yi_1j_1 <= temp_i_1j_1;


--FIFO i_2j
i_2j: PROCESS(clock)
BEGIN
    if(rising_edge(clock)) then
       -- if(we='1') then
				fifo_inst_i_2j(to_integer(unsigned(addr_w))) <= temp_i_1j_1;
       -- end if;
        s_yi_2j <= fifo_inst_i_2j(to_integer(unsigned(addr_r)));
    end if;
END PROCESS i_2j;
yi_2j <= s_yi_2j;


end Behavioral;

