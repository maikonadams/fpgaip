----------------------------------------------------------------------------------
-- Company:  student UofA
-- Engineer: maikon nascimento
-- 
-- Create Date:    12:15:28 02/11/2016 
-- Design Name: 
-- Module Name:    router - Behavioral 
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
--use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity routerMid is
generic(
		constant data_width : positive := 16;
		constant port_width : positive := 12;
		constant first_col : std_logic_vector :=   "000000000000"; -- 3
		constant first_row : std_logic_vector :=   "000000000000"; -- 3
		constant number_one : std_logic_vector :=  "000000000001"; -- 3
		constant last_row : std_logic_vector :=    "000000000011"; -- 3
		constant last_col : std_logic_vector :=    "000000000011"  --3
		
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
end routerMid;

architecture Behavioral of routerMid is

TYPE STATE_TYPE IS (clt, crt, clb, crb, bt, bb, bl, br, mid, iddle); --clt - corner left top , corner right 
SIGNAL state   : STATE_TYPE;

signal srow :  STD_LOGIC_VECTOR (port_width - 1 downto 0);

begin
-- implementing i -1 
srow <= row;
--srow <=  row - number_one when row > first_row else
--         last_row;

full_router3:process(yij, yi_1jp1, yi_1j, yi_1j_1, yi_2j)
--full_router3:process(clock)
begin
--	if rising_edge(clock) then
		if (srow = first_row) then
			if (col = first_col) then -- clt -----------ok
				state <= clt;
				oa <= yij;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_1jp1;
				oe <= yij;
			elsif (col = last_col) then -- crt  not
				state <= crt;
				oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_1j_1;
			else -- bt -----------------OK
				state <= bt;
				oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_1j_1;
			end if;
		elsif (srow = last_row) then
			if (col = first_col) then -- clb -------------ok
				state <= clb;
				oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_2j;
				oe <= yi_2j;
			elsif (col = last_col) then -- crb -------------ok
				state <= crb;
				oa <= yi_2j;
				ob <= yi_1j_1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_2j;
			else -- bb ------------------------------ok
				state <= bb;
				oa <= yi_1jp1;
				ob <= yi_1jp1;
				oc <= yi_1j ;
				od <= yi_1j_1;
				oe <= yi_1j_1;
			end if;
		else
			if (col = first_col) then -- bl
				state <= bl;
				oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_2j;
				oe <= yi_2j;
			elsif (col = last_col) then -- br
				state <= bt;
				oa <= yij;
				ob <= yij;
				oc <= yi_1j;
				od <= yi_2j;
				oe <= yi_2j;
			else -- mid
				state <= mid;
				oa <= yij;
				ob <= yi_1jp1;
				oc <= yi_1j;
				od <= yi_1j_1;
				oe <= yi_2j;
			end if;
		end if;
	--	end if;
end process;
					
--full_router3:process(yij, yi_1jp1, yi_1j, yi_1j_1, yi_2j, srow, col)
----full_router3:process(clock)
--begin
--	--if rising_edge(clock) then
--		if (srow = "00000000") and (col = "00000000") then --corner left top
--		   state <= clt;
--			oa <= yij;
--			ob <= yi_1jp1;
--			oc <= yi_1j;
--			od <= "0000000000000000";
--			oe <= "1111111111111111";
--		elsif (srow = "00000000") and (col = last_col) then -- corner right top
--		   state <= crt;
--			oa <= yij;
--			ob <= "0000000000000000";
--			oc <= yi_1j;
--			od <= yi_1j_1;
--			oe <= "1111111111111111";
--		elsif (srow = last_row) and (col = "00000000") then -- corner left bottom
--		   state <= clb;
--			oa <= "0000000000000000";
--			ob <= yi_1jp1;
--			oc <= yi_1j;
--			od <= "1111111111111111";
--			oe <= yi_2j;
--		elsif (srow = last_row) and (col = last_col) then -- corner right bottom
--		   state <= crb;
--			oa <= "0000000000000000" ;
--			ob <= "1111111111111111";
--			oc <= yi_1j;
--			od <=  yi_1j_1;
--			oe <= yi_2j;
--		elsif ((srow = "00000000" or srow = last_row) and ( col > "00000000" and col < last_col  )) then -- bar top
--	--	elsif (srow = "00000000") and ( col > "00000000" and col < last_col  ) then -- bar top
--		   state <= bt;
--			oa <= "1111111111111111";
--			ob <= yi_1jp1;
--			oc <=  yi_1j; 
--			od <= yi_1j_1;
--			oe <= "0000000000000000";
--		elsif ((srow >  "00000000" and srow < last_row )   and ( col  = "00000000" or col  = last_col))  then -- bar left last_col
--		--elsif (srow >  "00000000" and srow < last_row ) and ( col  = "00000000" ) then -- bar left last_col
--		   state <= bl;
--			oa <= yij;
--			ob <= "1111111111111111";
--			oc <= yi_1j;
--			od <= "0000000000000000";
--			oe <= yi_2j;
--		--elsif (srow >  "00000000" and srow < last_row ) and ( col > "00000000" and col < last_col   ) then -- mid
----    Mid is when row > "00000001" and (row <= last_row
--		else
--         state <= mid;
--			oa <= yij;
--			ob <= yi_1jp1;
--			oc <= yi_1j;
--			od <= yi_1j_1;
--			oe <= yi_2j;
----		else -- mid just in case
----		   state <= mid;
----			oa <= yij;
----			ob <= yi_1jp1;
----			oc <= yi_1j_1;
----			od <= yi_1j_1;
----			oe <= yi_2j;
--		end if;
----	else
----			state <= iddle;
----			oa <= (others => '0');
----			ob <= (others => '0');
----			oc <= (others => '0');
----			od <= (others => '0');
----			oe <= (others => '0');
----	end if;
--	--end if;
--end process;

--full_router3SAFEOK:process(yij, yi_1jp1, yi_1j, yi_1j_1, yi_2j)
----full_router3:process(clock)
--begin
----	if rising_edge(clock) then
--		if (srow = first_row) then
--			if (col = first_col) then -- clt
--				state <= clt;
--				oa <= yi_1j;
--				ob <= yij;
--				oc <= yi_1jp1;
--				od <= yij;
--				oe <= yi_1j;
--			elsif (col = last_col) then -- crt
--				state <= crt;
--				oa <= yi_1j;
--				ob <= yij;
--				oc <= yi_1j_1;
--				od <= yij;
--				oe <= yi_1j;
--			else -- bt
--				state <= bt;
--				oa <= yi_1j;
--				ob <= yi_1j_1;
--				oc <= yi_1jp1;
--				od <= yi_1j_1;
--				oe <= yi_1j;
--			end if;
--		elsif (srow = last_row) then
--			if (col = first_col) then -- clb
--				state <= clb;
--				oa <= yi_1j;
--				ob <= yi_2j;
--				oc <= yi_1jp1;
--				od <= yi_1jp1;
--				oe <= yi_1j;
--			elsif (col = last_col) then -- crb
--				state <= crb;
--				oa <= yi_1j;
--				ob <= yi_2j;
--				oc <= yi_1j_1;
--				od <= yi_2j;
--				oe <= yi_1j;
--			else -- bb
--				state <= bb;
--				oa <= yi_1j;
--				ob <= yi_1j_1;
--				oc <= yi_1jp1;
--				od <= yi_1jp1;
--				oe <= yi_1j;
--			end if;
--		else
--			if (col = first_col) then -- bl
--				state <= bl;
--				oa <= yi_1j;
--				ob <= yi_2j;
--				oc <= yij;
--				od <= yi_2j;
--				oe <= yij;
--			elsif (col = last_col) then -- br
--				state <= bt;
--				oa <= yi_1j;
--				ob <= yi_2j;
--				oc <= yij;
--				od <= yi_2j;
--				oe <= yij;
--			else -- mid
--				state <= mid;
--				oa <= yi_1j;
--				ob <= yi_2j;
--				oc <= yij;
--				od <= yi_1j_1;
--				oe <= yi_1jp1;
--			end if;
--		end if;
--	--	end if;
--end process full_router3SAFEOK;

end Behavioral;

