----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:59:15 11/25/2018 
-- Design Name: 
-- Module Name:    routerTable - Behavioral 
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

entity routerTable is
generic(
		constant data_width : positive := 16;
		constant port_width : positive := 2;
		constant first_col : std_logic_vector :=   "00"; -- 3
		constant first_row : std_logic_vector :=   "00"; -- 3
		constant number_one : std_logic_vector :=  "01"; -- 3
		constant last_row : std_logic_vector :=    "11"; -- 3
		constant last_col : std_logic_vector :=    "11"  --3
		
	 );
    Port ( 
			  clock : in  STD_LOGIC;
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
end routerTable;

architecture Behavioral of routerTable is

signal firstRow : std_logic;
signal firstCol : std_logic;
signal lastRow : std_logic;
signal lastCol : std_logic;

signal code : std_logic_vector(3 downto 0);

TYPE STATE_TYPE IS (clt, crt, clb, crb, bt, bb, bl, br, mid, iddle); --clt - corner left top , corner right 
SIGNAL state   : STATE_TYPE;
begin

firstRow <= '1' when row = first_row else '0';
firstCol <= '1' when col = first_col else '0';
lastRow <= '1' when row = last_row else '0';
lastCol <= '1' when col = last_col else '0';

code <= firstRow & lastRow & firstCol & lastCol;

router:process(yija, yi_1jp1b, yi_1jc, yi_1j_1d, yi_2je)
begin
	case code is
		when "1010" =>
			state <= clt;
			oa <= yija;
			ob <= yi_1jp1b;
			oc <= yi_1jc; 
			od <= yija; 
			oe <= yi_1jp1b; 
		when "1000" | "0100" =>
			state <= bt;
			oa <= yi_1jp1b;
			ob <= yi_1jp1b;
			oc <= yi_1jc; 
			od <= yi_1j_1d; 
			oe <= yi_1j_1d;
		when "1001" =>
			state <= crt;
			oa <= yija;
			ob <= yija;
			oc <= yi_1jc; 
			od <= yi_1j_1d; 
			oe <= yi_1j_1d;
		when "0010" | "0001" =>
			state <= bl;
			oa <= yija;
			ob <= yija;
			oc <= yi_1jc; 
			od <= yi_2je; 
			oe <= yi_2je;
		when "0000" =>
			state <= mid;
			oa <= yija;
			ob <= yi_1jp1b;
			oc <= yi_1jc; 
			od <= yi_1j_1d; 
			oe <= yi_2je;
--		when "0001" =>
--			state <= br;
--			oa <= yija;
--			ob <= yija;
--			oc <= yi_1jc; 
--			od <= yi_2je; 
--			oe <= yi_2je;
		when "0110" =>
			state <= clb;
			oa <= yi_1jp1b;
			ob <= yi_1jp1b;
			oc <= yi_1jc; 
			od <= yi_2je; 
			oe <= yi_2je;
--		when "0100" =>
--			state <= bb;
--			oa <= yi_1jp1b;
--			ob <= yi_1jp1b;
--			oc <= yi_1jc; 
--			od <= yi_1j_1d; 
--			oe <= yi_1j_1d;
		when "0101" =>
			state <= crb;
			oa <= yi_1j_1d;
			ob <= yi_2je;
			oc <= yi_1jc; 
			od <= yi_1j_1d; 
			oe <= yi_2je;
		when others => 
			state <= mid;
			oa <= yija;
			ob <= yi_1jp1b;
			oc <= yi_1jc; 
			od <= yi_1j_1d; 
			oe <= yi_2je;
end case;
end process router;


end Behavioral;

