----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:05:29 04/09/2018 
-- Design Name: 
-- Module Name:    spn - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spn is
generic( constant data_width : positive := 16; --16
			constant port_width : positive := 2;
			constant fifo_depth : positive := 8; --128 64*2 since image is 64x64
			--constant port_width_one : std_logic_vector := "0000000001";
			constant last_row : std_logic_vector :=       "11"; -- 1919 3 
			constant last_col : std_logic_vector :=       "11"  -- 1079  3
	);
    Port ( yij : in  STD_LOGIC_VECTOR (data_width -1 downto 0);
           row_addr : in  STD_LOGIC_VECTOR (port_width -1 downto 0);
           col_addr : in  STD_LOGIC_VECTOR (port_width -1 downto 0);
           clock : in  STD_LOGIC;
           median : out  STD_LOGIC_VECTOR (data_width -1 downto 0));
end spn;

architecture Behavioral of spn is

component fifoRam 
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
	end component;
	
component routerMid is
	generic(
		constant data_width : positive := 16;
		constant port_width : positive := 12;
		constant first_col : std_logic_vector :=   "000000000000"; -- 3
		constant first_row : std_logic_vector :=   "000000000000"; -- 3
		constant number_one : std_logic_vector :=  "000000000001"; -- 3
		constant last_row : std_logic_vector :=    "000000000011"; -- 3
		constant last_col : std_logic_vector :=    "000000000011"  --3
	 );
    Port ( clock : in  STD_LOGIC;
			  row : in  STD_LOGIC_VECTOR (port_width - 1 downto 0);
           col : in  STD_LOGIC_VECTOR (port_width - 1 downto 0);
           yij : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1jp1 : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1j : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1j_1 : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_2j : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oa : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           ob : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oc : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           od : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oe : out  STD_LOGIC_VECTOR (data_width - 1 downto 0));
end component;

component routerTable is
	generic(
		constant data_width : positive := 16;
		constant port_width : positive := 12;
		constant first_col : std_logic_vector :=   "000000000000"; -- 3
		constant first_row : std_logic_vector :=   "000000000000"; -- 3
		constant number_one : std_logic_vector :=  "000000000001"; -- 3
		constant last_row : std_logic_vector :=    "000000000011"; -- 3
		constant last_col : std_logic_vector :=    "000000000011"  --3
	 );
    Port ( clock : in  STD_LOGIC;
			  row : in  STD_LOGIC_VECTOR (port_width - 1 downto 0);
           col : in  STD_LOGIC_VECTOR (port_width - 1 downto 0);
           yija : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1jp1b : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1jc : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_1j_1d : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           yi_2je : in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oa : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           ob : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oc : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           od : out  STD_LOGIC_VECTOR (data_width - 1 downto 0);
           oe : out  STD_LOGIC_VECTOR (data_width - 1 downto 0));
end component;

component SorterMod is
generic (widthMaster : integer := 16);
Port (     ina : in  STD_LOGIC_VECTOR ((data_width -1) downto 0);
           inb : in  STD_LOGIC_VECTOR ((data_width -1) downto 0);
           inc : in  STD_LOGIC_VECTOR ((data_width -1) downto 0);
           ind : in  STD_LOGIC_VECTOR ((data_width -1) downto 0);
           ine : in  STD_LOGIC_VECTOR ((data_width -1) downto 0);
           clock : in  STD_LOGIC;
           median : out  STD_LOGIC_VECTOR ((data_width -1) downto 0));
end component;

signal syij : std_logic_vector(data_width -1 downto 0);
signal syi_1jp1 : std_logic_vector(data_width -1 downto 0);
signal syi_1j : std_logic_vector(data_width -1 downto 0);
signal syi_1j_1 : std_logic_vector(data_width -1 downto 0);
signal syi_2j : std_logic_vector(data_width -1 downto 0);

signal soa : std_logic_vector(data_width -1 downto 0);
signal sob : std_logic_vector(data_width -1 downto 0);
signal soc : std_logic_vector(data_width -1 downto 0);
signal sod : std_logic_vector(data_width -1 downto 0);
signal soe : std_logic_vector(data_width -1 downto 0);

constant port_width_1_zero : std_logic_vector(port_width -2 downto 0) := (others => '0');
constant port_width_one : std_logic_vector(port_width -1 downto 0) := port_width_1_zero&'1';
constant port_width_zero : std_logic_vector( port_width -1 downto 0) := (others=>'0');

begin

fifo_comp: fifoRam  generic map(data_width, fifo_depth)
                  port map(
									yin => yij,
									clock => clock,
									yij => syij,
									yi_1jp1 => syi_1jp1,
									yi_1j => syi_1j,
									yi_1j_1 => syi_1j_1,
									yi_2j => syi_2j);

-- router 
--router_inst: routerMid generic map (data_width, port_width,
--                                    port_width_zero, port_width_zero, port_width_one, -- "000000000000","000000000000","000000000001",
--                                    last_row, last_col )
--							  Port map ( clock => clock,
--											 row => row_addr,
--											 col => col_addr,
--											 yij => syij,
--											 yi_1jp1 => syi_1jp1,
--											 yi_1j => syi_1j,
--											 yi_1j_1 => syi_1j_1, 
--											 yi_2j => syi_2j,
--											 oa => soa,
--											 ob => sob,
--											 oc => soc,
--											 od => sod, 
--											 oe => soe);

router_inst: routerTable generic map (data_width, port_width,
                                    port_width_zero, port_width_zero, port_width_one, -- "000000000000","000000000000","000000000001",
                                    last_row, last_col )
							  Port map ( clock => clock,
											 row => row_addr,
											 col => col_addr,
											 yija => syij,
											 yi_1jp1b => syi_1jp1,
											 yi_1jc => syi_1j,
											 yi_1j_1d => syi_1j_1, 
											 yi_2je => syi_2j,
											 oa => soa,
											 ob => sob,
											 oc => soc,
											 od => sod, 
											 oe => soe);

-- median filter
sorter_comp: SorterMod  generic map (data_width)
								port map(
											ina => soa,
											inb => sob,
											inc => soc,
											ind => sod,
											ine => soe,
											clock => clock,
											median => median);

end Behavioral;