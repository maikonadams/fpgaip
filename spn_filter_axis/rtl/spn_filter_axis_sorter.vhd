-- 5 CLOCKS cycle to 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spn_filter_axis_sorter is
generic (
  G_PIXEL_DEPTH     : integer := 16
);
Port ( 
  il_clk            : in  std_logic;

  il_vld            : in  std_logic;
  ol_rdy            : out std_logic; 

  iv_a              : in  STD_LOGIC_VECTOR  ((G_PIXEL_DEPTH -1) downto 0);
  iv_b              : in  STD_LOGIC_VECTOR  ((G_PIXEL_DEPTH -1) downto 0);
  iv_c              : in  STD_LOGIC_VECTOR  ((G_PIXEL_DEPTH -1) downto 0);
  iv_d              : in  STD_LOGIC_VECTOR  ((G_PIXEL_DEPTH -1) downto 0);
  iv_e              : in  STD_LOGIC_VECTOR  ((G_PIXEL_DEPTH -1) downto 0);

  ov_med            : out  STD_LOGIC_VECTOR ((G_PIXEL_DEPTH -1) downto 0));
end spn_filter_axis_sorter;

architecture Behavioral of spn_filter_axis_sorter is

--first stage
signal sv_minComp1  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);
signal sv_maxComp1  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);
signal sv_outDelay1 : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);
signal sv_minComp2  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);
signal sv_maxComp2  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);

--second stage
signal sv_maxComp3  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0); 
signal sv_outDelay2 : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);   
signal sv_minComp4  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);

--third stage
signal sv_minComp5  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0); 
signal sv_maxComp5  : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0); 
signal sv_outDelay3 : std_logic_vector ((G_PIXEL_DEPTH -1) downto 0);

--forth stage
signal sv_minComp6  : std_logic_vector ((G_PIXEL_DEPTH  -1) downto 0);  
signal sv_outDelay4 : std_logic_vector ((G_PIXEL_DEPTH  -1) downto 0);

--first stage
signal sl_stage1    : std_logic;
signal sl_stage2    : std_logic;
signal sl_stage3    : std_logic;
signal sl_stage4    : std_logic;
signal sl_stage5    : std_logic;

begin

process (il_clk)
begin
  if rising_edge(il_clk) then
    sl_stage1   <=  il_vld;
    sl_stage2   <=  sl_stage1;
    sl_stage3   <=  sl_stage2;
    sl_stage4   <=  sl_stage3;
    sl_stage5   <=  sl_stage4;
  end if;
end process; 
ol_rdy          <=  sl_stage4;

comp1: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  iv_a, 
  iv_pix2       =>  iv_b,  
  ov_max        =>  sv_maxComp1, 
  ov_min        =>  sv_minComp1); 

process (il_clk)
begin
  if rising_edge(il_clk) then
    sv_outDelay1 <=  iv_c;    
  end if;
end process;  

comp2: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  iv_d, 
  iv_pix2       =>  iv_e,  
  ov_max        =>  sv_maxComp2, 
  ov_min        =>  sv_minComp2); 
				  				  
comp3: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  sv_minComp1, 
  iv_pix2       =>  sv_minComp2,  
  ov_max        =>  sv_maxComp3, 
  ov_min        =>  open);

process (il_clk)
begin
  if rising_edge(il_clk) then
    sv_outDelay2 <= sv_outDelay1;    
  end if;
end process; 

comp4: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  sv_maxComp1, 
  iv_pix2       =>  sv_maxComp2,  
  ov_max        =>  open, 
  ov_min        =>  sv_minComp4);

process (il_clk)
begin
  if rising_edge(il_clk) then
    sv_outDelay3 <= sv_minComp4;    
  end if;
end process;
					
comp5: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  sv_maxComp3, 
  iv_pix2       =>  sv_outDelay2,  
  ov_max        =>  sv_maxComp5, 
  ov_min        =>  sv_minComp5);
				 
process (il_clk)
begin
  if rising_edge(il_clk) then
    sv_outDelay4 <= sv_minComp5;    
  end if;
end process;				  
						  
comp6: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  sv_maxComp5, 
  iv_pix2       =>  sv_outDelay3,  
  ov_max        =>  open, 
  ov_min        =>  sv_minComp6);
				  
comp7: entity work.spn_filter_axis_maxMin 
generic map(
  G_PIXEL_DEPTH =>  G_PIXEL_DEPTH) 
port map   (
  il_clk        =>  il_clk, 
  iv_pix1       =>  sv_outDelay4, 
  iv_pix2       =>  sv_minComp6,  
  ov_max        =>  ov_med, 
  ov_min        =>  open);


end Behavioral;