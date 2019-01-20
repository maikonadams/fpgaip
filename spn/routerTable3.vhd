----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:14:41 09/10/2018 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity routerTable is
generic(
		constant data_width : positive := 4;
		constant port_width : positive := 3;
		constant last_row : std_logic_vector :=    "101"; -- 5
		constant last_col : std_logic_vector :=    "100"  --4
		
	 );
    Port ( 
			  clock : in  STD_LOGIC;
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
end routerTable;

architecture Behavioral of routerTable is

constant FIRST_COL : std_logic_vector(port_width - 1 downto 0) :=   (others=>'0'); -- 3
constant FIRST_ROW : std_logic_vector(port_width - 1 downto 0) :=   (others=>'0'); -- 3
constant TEMP_ZERO : std_logic_vector(port_width - 1 downto 1) :=   (others=>'0'); -- 3
constant NUM_ONE : std_logic_vector(port_width - 1 downto 0) :=  TEMP_ZERO&'1'; -- 3

TYPE STATE_TYPE IS (clt, crt, clb, crb, bt, bb, bl, br, mid, idle); --clt - corner left top , corner right 
SIGNAL state   : STATE_TYPE;

signal isRowFirst : std_logic;
signal isRowLast : std_logic;
signal isColFirst : std_logic;
signal isColLast : std_logic;

signal encoder : std_logic_vector(3 downto 0);

begin

isRowFirst <= '1' when row = FIRST_ROW else '0';
isRowLast  <= '1' when row = last_row  else '0';
isColFirst <= '1' when col = FIRST_COL else '0';
isColLast  <= '1' when col = last_col else '0';

encoder <= isRowFirst&isRowLast&isColFirst&isColLast;

--full_router3:process(yij, yi_1jp1, yi_1j, yi_1j_1, yi_2j)
--oa <= yij     when encoder = "1010" else
--      yi_1jp1 when encoder = "1000" else
--		yij     when encoder = "1001" else
--		yij     when encoder = "0010" else
--		yij     when encoder = "0000" else
--		yij     when encoder = "0001" else
--		yi_1jp1 when encoder = "0110" else
--		yi_1jp1 when encoder = "0100" else
--		yi_2j   when encoder = "0101";
--		
--ob <= yi_1jp1 when encoder = "1010" else
--      yi_1jp1 when encoder = "1000" else
--		yij     when encoder = "1001" else
--		yij     when encoder = "0010" else
--		yi_1jp1 when encoder = "0000" else
--		yij     when encoder = "0001" else
--		yi_1jp1 when encoder = "0110" else
--		yi_1jp1 when encoder = "0100" else
--		yi_1j_1 when encoder = "0101";
--		
--oc <= yi_1j;
--		
--od <= yi_1jp1     when encoder = "1010" else
--      yi_1j_1 when encoder = "1000" else
--		yi_1j_1     when encoder = "1001" else
--		yi_2j     when encoder = "0010" else
--		yi_1j_1     when encoder = "0000" else
--		yi_2j     when encoder = "0001" else
--		yi_2j when encoder = "0110" else
--		yi_1j_1 when encoder = "0100" else
--		yi_1j_1   when encoder = "0101";
--		
--oe <= yij     when encoder = "1010" else
--      yi_1j_1 when encoder = "1000" else
--		yi_1j_1     when encoder = "1001" else
--		yi_2j     when encoder = "0010" else
--		yi_2j     when encoder = "0000" else
--		yi_2j     when encoder = "0001" else
--		yi_2j when encoder = "0110" else
--		yi_1j_1 when encoder = "0100" else
--		yi_2j   when encoder = "0101";
--
--state <= clt     when encoder = "1010" else
--			bt when encoder = "1000" else
--			crt     when encoder = "1001" else
--			bl     when encoder = "0010" else
--			mid     when encoder = "0000" else
--			br     when encoder = "0001" else
--			clb when encoder = "0110" else
--			bb when encoder = "0100" else
--			crb   when encoder = "0101";


full_router3:process(yij,yi_1jp1,yi_1j,yi_1j_1,yi_2j)
	--variable 
begin
	case encoder is
		when "1010" =>
			state <= clt;
			oa <= yij;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_1jp1;
				oe <= yij;
		when "1000" =>
			state <= bt;
			oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_1j_1;
		when "1001" =>
			state <= crt;
			oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_1j_1;
		when "0010" =>
			state <= bl;
			oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_2j;
				oe <= yi_2j;
		when "0000" =>
			state <= mid;
			oa <= yij;
				ob <= yi_1jp1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_2j;
		when "0001" =>
			state <= br;
			oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_2j;
				oe <= yi_2j;
		when "0110" =>
			state <= clb;
			oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_2j;
				oe <= yi_2j;
		when "0100" =>	
			state <= bb;
			oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_1j_1;
				oe <= yi_1j_1;
		when "0101" =>
			state <= crb;
			oa <= yi_2j;
				ob <= yi_1j_1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_2j;
		when others =>
			state <= idle;
	end case;
end process full_router3;
 
end Behavioral;

