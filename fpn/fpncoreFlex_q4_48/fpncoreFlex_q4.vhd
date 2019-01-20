-----------------------------------------------------------------
-----this code is auto-generated from a Matlab Script ---------- 
-------------  Maikon Nascimento 	12-Jun-2018------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;



entity 	fpncoreFlex_q4 is 
	 generic (width_data : positive := 16;
			 tk4: positive :=7;
			 tk3: positive :=10;
			 tk2: positive :=10;
			 tk1: positive :=10;
			 tk0: positive :=11);
	 Port ( clock : in  STD_LOGIC;
			 yij : in  STD_LOGIC_VECTOR ((width_data - 1) downto 0);
			 aj : in  STD_LOGIC_VECTOR ((48 - 1) downto 0);
			 yhj : out  STD_LOGIC_VECTOR ((width_data - 1) downto 0));
end 	fpncoreFlex_q4;

architecture Behavioral of 	fpncoreFlex_q4 is

 component delay1
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

 component delay8
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed8 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
 end component;

 component delay9
	 generic (width_data : integer := (width_data ));
	 Port ( clock : in  STD_LOGIC;
		 yin : in  STD_LOGIC_VECTOR ((width_data-1) downto 0);
		 ydelayed9 : out  STD_LOGIC_VECTOR ((width_data-1) downto 0));
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
signal aij4 :  STD_LOGIC_VECTOR ((tk4 - 1) downto 0);
signal aij3 :  STD_LOGIC_VECTOR ((tk3 - 1) downto 0);
signal aij2 :  STD_LOGIC_VECTOR ((tk2 - 1) downto 0);
signal aij1 :  STD_LOGIC_VECTOR ((tk1 - 1) downto 0);
signal aij0 :  STD_LOGIC_VECTOR ((tk0 - 1) downto 0);
signal busDelay9 : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  
signal yijbus : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  
signal busAdderTop : STD_LOGIC_VECTOR ((width_data - 1) downto 0);  

signal busDelay1 : STD_LOGIC_VECTOR ((tk4- 1) downto 0);  
----- branch first delays1 signals out delay -------- 
signal busDelay2 : STD_LOGIC_VECTOR ((tk3 - 1) downto 0);  
----- branch first delays2 signals out delay -------- 
signal busDelay4 : STD_LOGIC_VECTOR ((tk2 - 1) downto 0);  
----- branch first delays3 signals out delay -------- 
signal busDelay6 : STD_LOGIC_VECTOR ((tk1 - 1) downto 0);  
----- branch first delays4 signals out delay -------- 
signal busDelay8 : STD_LOGIC_VECTOR ((tk0 - 1) downto 0);  


----- branch4 signals -------- 
signal delay_z2_b4: std_logic_vector(width_data -1 downto 0);
signal oMultB4:STD_LOGIC_VECTOR (23-1 downto 0);  
signal carry_b4: STD_LOGIC;
signal oBSBranch4:STD_LOGIC_VECTOR ((11-1) downto 0);  
----- branch3 signals out delay -------- 
signal delay_z2_b3: std_logic_vector(width_data -1 downto 0);
signal oAdderB3:STD_LOGIC_VECTOR (11-1 downto 0);  
signal oMultB3:STD_LOGIC_VECTOR (27-1 downto 0);  
signal carry_b3: STD_LOGIC;
signal oBSBranch3:STD_LOGIC_VECTOR (15-1 downto 0);  
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
signal oBSBranch1:STD_LOGIC_VECTOR (25-1 downto 0);  
----- branch0 signals out delay -------- 
signal oAdderB0:STD_LOGIC_VECTOR (25-1 downto 0);  
signal oBSBranch0:STD_LOGIC_VECTOR (width_data -1 downto 0);  


begin 

--------------- branch DEMUX 
aij0 <= aj(10 downto 	0);
aij1 <= aj(20 downto 	11);
aij2 <= aj(30 downto 	21);
aij3 <= aj(40 downto 	31);
aij4 <= aj(47 downto 	41);
--------------- branch TOP 
yijbus <= yij;  
addertop_u: adderFlex2 generic map(width_data, width_data, width_data) port map(yijbus, y0bus,clock, busAdderTop);
delaytop_u: delay9 generic map(width_data) port map(clock, yijbus,busDelay9);



 ----- branch4-------- 
delay_z2_b4 <=busAdderTop;
delay1_u_b4: delay1 generic map(7) port map(clock,aij4,busDelay1); 
mult_u_b4: multiplierFlex generic map(7,width_data,23) port map(busDelay1, busAdderTop,clock,oMultB4);
genCarry_u_b4 :generateCarryAuto generic map(23,12)port map(oMultB4,carry_b4);
oBSBranch4<= oMultB4(23 - 1 downto 	12); 


 ----- branch3-------- 
delayz2b3Att : delay2 generic map(width_data) port map(clock,delay_z2_b4, delay_z2_b3);
delay2_u_b3: delay2 generic map(10) port map(clock,aij3,busDelay2); 
adder_u_b3: adderFlexwCarry generic map(10,11,11) port map(busDelay2, oBSBranch4,carry_b4 , clock, oAdderB3);
mult_u_b3: multiplierFlex generic map(11,width_data,27) port map(oAdderB3,delay_z2_b3, clock,oMultB3);
genCarry_u_b3 :generateCarryAuto generic map(27,12)port map(oMultB3,carry_b3);
oBSBranch3<= oMultB3(26  downto 	12); 


 ----- branch2-------- 
delayz2b2Att : delay2 generic map(width_data) port map(clock,delay_z2_b3, delay_z2_b2);
delay4_u_b2: delay4 generic map(10) port map(clock,aij2,busDelay4); 
adder_u_b2: adderFlexwCarry generic map(10,15,15) port map(busDelay4, oBSBranch3,carry_b3 , clock, oAdderB2);
mult_u_b2: multiplierFlex generic map(15,width_data,31) port map(oAdderB2,delay_z2_b2, clock,oMultB2);
genCarry_u_b2 :generateCarryAuto generic map(31,12)port map(oMultB2,carry_b2);
oBSBranch2<= oMultB2(30  downto 	12); 


 ----- branch1-------- 
delayz2b1Att : delay2 generic map(width_data) port map(clock,delay_z2_b2, delay_z2_b1);
delay6_u_b1: delay6 generic map(10) port map(clock,aij1,busDelay6); 
adder_u_b1: adderFlexwCarry generic map(10,19,19) port map(busDelay6, oBSBranch2,carry_b2 , clock, oAdderB1);
mult_u_b1: multiplierFlex generic map(19,width_data,35) port map(oAdderB1,delay_z2_b1, clock,oMultB1);
genCarry_u_b1 :generateCarryAuto generic map(35,10)port map(oMultB1,carry_b1);
oBSBranch1<= oMultB1(34  downto 	10); 


 ----- branch0-------- 
delay8_u_b0: delay8 generic map(11) port map(clock,aij0,busDelay8); 
adder_u_b0: adderFlexwCarry generic map(11,25,25) port map(busDelay8, oBSBranch1,carry_b1,clock, oAdderB0);
oBSBranch0 <= oAdderB0(width_data -4 - 1 downto 0) &"0000"; 
adder_u_Lastb: adderFlex2 generic map(16,16,16) port map (oBSBranch0, busDelay9,clock, yhj);

 end Behavioral;