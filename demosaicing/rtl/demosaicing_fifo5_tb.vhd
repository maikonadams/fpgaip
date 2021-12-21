library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.math_real."log2";
use IEEE.math_real."round"; 

library work;
use work.comm_types_pkg.all;

LIBRARY modelsim_lib;
use modelsim_lib.util.all;

ENTITY demosaicing_fifo5_tb IS
generic(

  constant GS_input_axis_image_vectors       : string  := 
       "/home/maikon/Dropbox/PhDSafe/ong_prj/rtlsimlib/isp/spn_filter_axis/input_data/input_axis_image_vectors.txt";
  constant GS_output_axis_image_vectors      : string  := 
       "/home/maikon/Dropbox/PhDSafe/ong_prj/rtlsimlib/isp/spn_filter_axis/output_data/output_axis_image_vectors.txt";
  constant GI_PIXEL_DEPTH                  : integer := 4; 
  constant GI_IMG_WIDTH                    : integer := 7;
  constant GI_IMG_HEIGHT                   : integer := 7;
  constant GI_MASK_SIZE                    : integer := 3;
  constant GI_MASK_SIZE5                   : integer := 5;
  constant GI_MASK_SIZE7                   : integer := 7;
  constant GI_NUM_OF_FRAMES                : integer := 2 

);
END demosaicing_fifo5_tb;
 
ARCHITECTURE behavior OF demosaicing_fifo5_tb IS

signal sl_clk                         :   std_logic:='0';
signal sl_rst                         :   std_logic:='0';

signal sl_wr                          :  std_logic := '0'; -- coming from the Master input
signal sl_rd                          :  std_logic := '0'; -- coming from the slave output

signal sv_pixel                       :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');

signal sv_i                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');
signal sv_h                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0):= (others=>'0');
signal sv_g                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_f                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_e                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_d                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_c                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_b                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);
signal sv_a                           :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);

signal sv_e1                          :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');
signal sv_d1                          :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');
signal sv_c1                          :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');
signal sv_b1                          :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');
signal sv_a1                          :  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0) := (others=>'0');

signal snv_mask                       : std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);
signal svn_mask3                      : std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);

signal svn_mask5                      : std_logic_vector_xN(GI_MASK_SIZE5*GI_MASK_SIZE5 -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);
signal svn_mask5gen                   : std_logic_vector_xN(GI_MASK_SIZE5*GI_MASK_SIZE5 -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);
signal svn_mask5genv2                 : std_logic_vector_xN(GI_MASK_SIZE5*GI_MASK_SIZE5 -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);
signal ovn_mask_sl                    : std_logic_vector_xN(GI_MASK_SIZE7 -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);

signal sl_simulation_done             : std_logic := '0';
-- Clock period definitions
constant clock_period : time          := 10 ns;

begin
------------------------------------------------------------------------------
-- Clock and Reset
------------------------------------------------------------------------------

sl_rst             <= '0' after  100 ns;
--sl_clk             <= '0' when (sl_simulation_done = '1') else not sl_clk after  10 ns;

-- Clock process definitions
clock_process :process
begin
  sl_clk <= '0';
  wait for clock_period/2;
  sl_clk <= '1';
  wait for clock_period/2;
end process;

------------------------------------------------------------------------------
-- circuit under test
------------------------------------------------------------------------------

demosaicing_fifo5_inst5 : entity work.demosaicing_fifo5
  generic map
  (
    GI_MASK_SIZE                    => GI_MASK_SIZE5, --GI_MASK_SIZE5
    GI_PIXEL_DEPTH                  => GI_PIXEL_DEPTH,
    GI_IMG_WIDTH                    => GI_IMG_WIDTH
  )
  port map
  (
    il_clk                          => sl_clk,
    il_rst                          => sl_rst,

    il_move                         => sl_wr,
    iv_pixel                        => sv_pixel,

    ovn_mask                        => svn_mask5
  );

demosaicing_fifo5_inst5gen : entity work.demosaicing_fifo5gen
  generic map
  (
    GI_MASK_SIZE                    => GI_MASK_SIZE5, --GI_MASK_SIZE5
    GI_PIXEL_DEPTH                  => GI_PIXEL_DEPTH,
    GI_IMG_WIDTH                    => GI_IMG_WIDTH
  )
  port map
  (
    il_clk                          => sl_clk,
    il_rst                          => sl_rst,

    il_wr                           => sl_wr,
    il_rd                           => sl_rd,
    iv_pixel                        => sv_pixel,

    ovn_mask                        => svn_mask5gen
  );

demosaicing_fifo5_inst5genv2 : entity work.demosaicing_fifo5genv2
  generic map
  (
    GI_MASK_SIZE                    => GI_MASK_SIZE5, --GI_MASK_SIZE5
    GI_PIXEL_DEPTH                  => GI_PIXEL_DEPTH,
    GI_IMG_WIDTH                    => GI_IMG_WIDTH
  )
  port map
  (
    il_clk                          => sl_clk,
    il_rst                          => sl_rst,

    il_wr                           => sl_wr,
    il_rd                           => sl_rd,
    iv_pixel                        => sv_pixel,

    ovn_mask                        => svn_mask5genv2
  );

  -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      
      sl_simulation_done <= '0';
      wait for clock_period*1;
      sl_wr    <= '1';
      sv_pixel <= x"0";
      wait for clock_period*1;
      sv_pixel <= x"1";
      wait for clock_period*1;
      sv_pixel <= x"2";
      wait for clock_period*1;
      sv_pixel <= "0011";

      wait for clock_period*1;
      sv_pixel <= "0100";
      wait for clock_period*1;
      sv_pixel <= "0101";
      wait for clock_period*1;
      sv_pixel <= "0110";
      wait for clock_period*1;
      sv_pixel <= "0111";

      wait for clock_period*1;
      sv_pixel <= "1000";
      wait for clock_period*1;
      sv_pixel <= "1001";
      wait for clock_period*1;
      sv_pixel <= "1010";
      wait for clock_period*1;
      sv_pixel <= "1011";

      wait for clock_period*1;
      sv_pixel <= "1100";
      wait for clock_period*1;
      sv_pixel <= "1101";
      wait for clock_period*1;
      sv_pixel <= "1110";
      wait for clock_period*1;
      sv_pixel <= "1111";

      wait for clock_period*1;
      sv_pixel <= x"0";
      wait for clock_period*1;
      sv_pixel <= x"1";
      wait for clock_period*1;
      sv_pixel <= x"2";
      wait for clock_period*1;
      sv_pixel <= x"3";

      wait for clock_period*1;
      sv_pixel <= x"4";
      wait for clock_period*1;
      sv_pixel <= x"5";
      wait for clock_period*1;
      sv_pixel <= x"6";
      wait for clock_period*1;
      sv_pixel <= x"7";

      wait for clock_period*1;
      sv_pixel <= x"8";
      wait for clock_period*1;
      sv_pixel <= x"9";
      wait for clock_period*1;
      sv_pixel <= "1010";
      wait for clock_period*1;
      sv_pixel <= "1011";

      wait for clock_period*1;
      sv_pixel <= "1100";
      wait for clock_period*1;
      sv_pixel <= "1101";
      wait for clock_period*1;
      sv_pixel <= "1110";
      wait for clock_period*1;
      sv_pixel <= "1111";

      wait for clock_period*1;
      sv_pixel <= x"0";
      wait for clock_period*1;
      sv_pixel <= x"1";
      wait for clock_period*1;
      sv_pixel <= x"2";
      wait for clock_period*1;
      sv_pixel <= "0011";

      wait for clock_period*1;
      sv_pixel <= "0100";
      wait for clock_period*1;
      sv_pixel <= "0101";
      wait for clock_period*1;
      sv_pixel <= "0110";
      wait for clock_period*1;
      sv_pixel <= "0111";

      wait for clock_period*1;
      sv_pixel <= "1000";
      wait for clock_period*1;
      sv_pixel <= "1001";
      wait for clock_period*1;
      sv_pixel <= "1010";
      wait for clock_period*1;
      sv_pixel <= "1011";

      wait for clock_period*1;
      sl_simulation_done <= '1';
      sl_wr    <= '0';
      
   end process;


end behavior;