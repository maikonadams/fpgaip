-----------------------------------------------------------------
-----this code is auto-generated from a Matlab Script ---------- 
-------------  Maikon Nascimento 	12-Jun-2018------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity 	fpncoreFlex_q3 is 
	 generic (width_data : positive := 16;
			 tk3: positive :=11;
			 tk2: positive :=12;
			 tk1: positive :=13;
			 tk0: positive :=12);
	 Port ( clock : in  STD_LOGIC;
			 yij : in  STD_LOGIC_VECTOR ((width_data - 1) downto 0);
			 aj : in  STD_LOGIC_VECTOR ((48 - 1) downto 0);
			 yhj : out  STD_LOGIC_VECTOR ((width_data - 1) downto 0));
end 	fpncoreFlex_q3;

architecture Behavioral of 	fpncoreFlex_q3 is

 component delay1b
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed1 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

 component delay2
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed2 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

 component delay4
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed4 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

 component delay6
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed6 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

 component delay7
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed7 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

component adderFlexwCarry is
	 generic (adder1_width : positive := 9;
		      adder2_width : positive := 11;
		      sum_width : positive := 11);
	 port (adder1in : in  STD_LOGIC_VECTOR ((adder1_width - 1) downto 0);
		   adder2in : in  STD_LOGIC_VECTOR ((adder2_width - 1) downto 0);
		   carry : in  STD_LOGIC;
		  clock : in  STD_LOGIC;
		     sum : out  STD_LOGIC_VECTOR ((sum_width - 1) downto 0));
end component;

component adderFlex2 is
	 generic (adder1_width : positive := 9;
		      adder2_width : positive := 11;
		      sum_width : positive := 11);
	 port (adder1in : in  STD_LOGIC_VECTOR ((adder1_width - 1) downto 0);
		   adder2in : in  STD_LOGIC_VECTOR ((adder2_width - 1) downto 0);
		  clock : in  STD_LOGIC;
		     sum : out  STD_LOGIC_VECTOR ((sum_width - 1) downto 0));
end component;

component multiplierFlex is
	 generic (mult1_width : positive := 16;
		      mult2_width : positive := 16;
		      multOut_width : positive := 32);
	 port (mult1 : in  STD_LOGIC_VECTOR ((mult1_width - 1) downto 0);
		   mult2 : in  STD_LOGIC_VECTOR ((mult2_width - 1) downto 0);
		  clock : in  STD_LOGIC;
		   multOut : out  STD_LOGIC_VECTOR ((multOut_width - 1) downto 0));
end component;

component generateCarryAuto 
	 generic (word_width : positive := 25;
		        tk : positive := 12);
	 port (fromMult : in  STD_LOGIC_VECTOR ((word_width - 1) downto 0);
		     carry : out  STD_LOGIC);
end component;

---- CONSTANTs ------ 
constant y0bus : STD_LOGIC_VECTOR ((width_data - 1) downto 0) := "1001101111100111"; -- -25625   

---- SIGNALS ------ 
signal aij3 :  STD_LOGIC_VECTOR ((tk3 - 1) downto 0);
signal aij2 :  STD_LOGIC_VECTOR ((tk2 - 1) downto 0);
signal aij1 :  STD_LOGIC_VECTOR ((tk1 - 1) downto 0);
signal aij0 :  STD_LOGIC_VECTOR ((tk0 - 1) downto 0);
signal busDelay7 : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  
signal yijbus : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  
signal busAdderTop : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  

signal busDelay1 : STD_LOGIC_VECTOR ((tk3- 1) downto 0);  
----- branch first delays1 signals out delay -------- 
signal busDelay2 : STD_LOGIC_VECTOR ((tk2 - 1) downto 0);  
----- branch first delays2 signals out delay -------- 
signal busDelay4 : STD_LOGIC_VECTOR ((tk1 - 1) downto 0);  
----- branch first delays3 signals out delay -------- 
signal busDelay6 : STD_LOGIC_VECTOR ((tk0 - 1) downto 0);  


----- branch3 signals -------- 
signal delay_z2_b3: std_logic_vector(width_data -1 downto 0);
signal oMultB3:STD_LOGIC_VECTOR (27-1 downto 0);  
signal carry_b3: STD_LOGIC;
signal oBSBranch3:STD_LOGIC_VECTOR ((15-1) downto 0);  
----- branch2 signals out delay -------- 
signal delay_z2_b2: std_logic_vector(width_data -1 downto 0);
signal oAdderB2:STD_LOGIC_VECTOR (15-1 downto 0);  
signal oMultB2:STD_LOGIC_VECTOR (31-1 downto 0);  
signal carry_b2: STD_LOGIC;
signal oBSBranch2:STD_LOGIC_VECTOR (19-1 downto 0);  
----- branch1 signals out delay -------- 
signal delay_z2_b1: std_logic_vector(width_data -1 downto 0);
signal oAdderB1:STD_LOGIC_VECTOR (19-1 downto 0);  
signal oMultB1:STD_LOGIC_VECTOR (35-1 downto 0);  
signal carry_b1: STD_LOGIC;
signal oBSBranch1:STD_LOGIC_VECTOR (23-1 downto 0);  
----- branch0 signals out delay -------- 
signal oAdderB0:STD_LOGIC_VECTOR (23-1 downto 0);  
signal oBSBranch0:STD_LOGIC_VECTOR (width_data -1 downto 0);  


begin 

--------------- branch DEMUX 
aij0 <= aj(11 downto 	0);
aij1 <= aj(24 downto 	12);
aij2 <= aj(36 downto 	25);
aij3 <= aj(47 downto 	37);
--------------- branch TOP 
yijbus <= yij;  
addertop_u: adderFlex2 generic map(width_data, width_data, width_data) port map(yijbus, y0bus,clock, busAdderTop);
delaytop_u: delay7 generic map(width_data) port map(clock, yijbus,busDelay7);



 ----- branch3-------- 
delay_z2_b3 <=busAdderTop;
delay1_u_b3: delay1b generic map(11) port map(clock,aij3,busDelay1); 
mult_u_b3: multiplierFlex generic map(11,width_data,27) port map(busDelay1, busAdderTop,clock,oMultB3);
genCarry_u_b3 :generateCarryAuto generic map(27,12)port map(oMultB3,carry_b3);
oBSBranch3<= oMultB3(27 - 1 downto 	12); 


 ----- branch2-------- 
delayz2b2Att : delay2 generic map(width_data) port map(clock,delay_z2_b3, delay_z2_b2);
delay2_u_b2: delay2 generic map(12) port map(clock,aij2,busDelay2); 
adder_u_b2: adderFlexwCarry generic map(12,15,15) port map(busDelay2, oBSBranch3,carry_b3 , clock, oAdderB2);
mult_u_b2: multiplierFlex generic map(15,width_data,31) port map(oAdderB2,delay_z2_b2, clock,oMultB2);
genCarry_u_b2 :generateCarryAuto generic map(31,12)port map(oMultB2,carry_b2);
oBSBranch2<= oMultB2(30  downto 	12); 


 ----- branch1-------- 
delayz2b1Att : delay2 generic map(width_data) port map(clock,delay_z2_b2, delay_z2_b1);
delay4_u_b1: delay4 generic map(13) port map(clock,aij1,busDelay4); 
adder_u_b1: adderFlexwCarry generic map(13,19,19) port map(busDelay4, oBSBranch2,carry_b2 , clock, oAdderB1);
mult_u_b1: multiplierFlex generic map(19,width_data,35) port map(oAdderB1,delay_z2_b1, clock,oMultB1);
genCarry_u_b1 :generateCarryAuto generic map(35,12)port map(oMultB1,carry_b1);
oBSBranch1<= oMultB1(34  downto 	12); 


 ----- branch0-------- 
delay6_u_b0: delay6 generic map(12) port map(clock,aij0,busDelay6); 
adder_u_b0: adderFlexwCarry generic map(12,23,23) port map(busDelay6, oBSBranch1,carry_b1,clock, oAdderB0);
oBSBranch0 <= oAdderB0(width_data -2 - 1 downto 0) &"00"; 
adder_u_Lastb: adderFlex2 generic map(16,16,16) port map (oBSBranch0, busDelay7,clock, yhj);

 end Behavioral;