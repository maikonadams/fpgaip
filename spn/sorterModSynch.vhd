----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:59:51 11/11/2015 
-- Design Name: 
-- Module Name:    SorterTop - Behavioral 
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

entity SorterModSynch is
	 generic (widthMaster : integer := 16);
    Port ( ina2 : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
           inb2 : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
           inc2 : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
           ind2 : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
           ine2 : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
           clock : in  STD_LOGIC;
           median : out  STD_LOGIC_VECTOR ((widthMaster -1) downto 0));
end SorterModSynch;

architecture Behavioral of SorterModSynch is

component delayOneClk is
generic (width : integer);
Port ( inz : in  STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
			  clock : in std_logic;
           inz_1 : out  STD_LOGIC_VECTOR ((widthMaster -1) downto 0));
end component;

component MaxMin is
    generic (width : integer);
    Port ( in1 : in  STD_LOGIC_VECTOR ((widthMaster-1) downto 0);
           in2 : in  STD_LOGIC_VECTOR ((widthMaster-1) downto 0);
		   clock : in std_logic;
           max : out  STD_LOGIC_VECTOR (( widthMaster -1) downto 0);
           min : out  STD_LOGIC_VECTOR ((widthMaster -1) downto 0));
end component;

--first stage
signal minComp1, maxComp1, 
		 outDelay1, minComp2, maxComp2 : std_logic_vector ((widthMaster-1) downto 0);

--second stage
signal maxComp3, outDelay2, minComp4 : std_logic_vector ((widthMaster-1) downto 0);

--third stage
signal minComp5, maxComp5, outDelay3 : std_logic_vector ((widthMaster-1) downto 0);

--forth stage
signal minComp6,  outDelay4 : std_logic_vector ((widthMaster-1) downto 0);

signal ina :   STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
signal inb :   STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
signal inc :   STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
signal ind :   STD_LOGIC_VECTOR ((widthMaster -1) downto 0);
signal ine :   STD_LOGIC_VECTOR ((widthMaster -1) downto 0);

--garbage signal
begin

process(clock)
begin
if rising_edge(clock) then
	ina <= ina2;
	inb <= inb2;
	inc <= inc2;
	ind <= ind2;
	ine <= ine2;
end if;
end process;

-- switch between MaxMin and MaxMinTop
comp1: MaxMin generic map(width => widthMaster) 
				  port map(ina, inb, clock, maxComp1, minComp1); 
				
delay1: delayOneClk generic map(width => widthMaster)
						  port map(inc, clock, outDelay1);  

comp2: MaxMin generic map(width => widthMaster )
				  port map(ind, ine, clock, maxComp2, minComp2);
				  				  
comp3: MaxMin generic map(width => widthMaster) 
				  port map(minComp1, minComp2, clock, maxComp3, open);

delay2: delayOneClk generic map(width => widthMaster)
						  port map(outDelay1, clock, outDelay2);

comp4: MaxMin generic map(width => widthMaster )
				  port map(maxComp1, maxComp2, clock, open, minComp4);


delay3: delayOneClk generic map(width => widthMaster)
						  port map(minComp4, clock, outDelay3);
					
comp5: MaxMin generic map(width => widthMaster )
				  port map(maxComp3, outDelay2, clock, maxComp5, minComp5);
				  
delay4: delayOneClk generic map(width => widthMaster)
						  port map(minComp5, clock, outDelay4);				  
						  
comp6: MaxMin generic map(width => widthMaster )
				  port map(maxComp5, outDelay3, clock, open, minComp6);
				  
comp7: MaxMin generic map(width => widthMaster )
				  port map(outDelay4, minComp6, clock, median, open);
				  
end Behavioral;

