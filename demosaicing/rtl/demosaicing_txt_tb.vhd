
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

use ieee.std_logic_textio.all;

entity demosaicing_txt_tb is
generic
(
  gs_IMAGE_input                            : string  := 
    "../input_data/input_image.txt";
  gs_IMAGE_expected_output                  : string  := 
    "../input_data/expected_output_image.txt";
  gs_rtl_output                             : string  := 
    "../output_data/rtl_output.txt";
  GI_PIXEL_WIDTH                            : integer := 8; 
  GI_NUM_FRAMES                             : integer := 1;
  GI_IMG_WIDTH                              : integer := 768;
  GI_IMG_HEIGHT                             : integer := 512 
);
end demosaicing_txt_tb;

ARCHITECTURE behavior OF demosaicing_txt_tb IS
  -- Clock period definitions
  constant clock_period                     : time  := 10 ns;
  constant CI_NUM_OF_PIXELS                 : integer := (GI_IMG_WIDTH*GI_IMG_HEIGHT*GI_NUM_FRAMES);
  constant CI_NUM_OF_PIXELS_BITS            : integer := integer(ceil(log2(real(GI_IMG_WIDTH*GI_IMG_HEIGHT*GI_NUM_FRAMES))));

  signal sl_clk                             : std_logic := '0';
  signal sl_rst                             : std_logic := '0'; 

  signal sv_s_axis_tdata                    : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal sl_s_axis_tlast                    : std_logic;
  signal sl_s_axis_tvalid                   : std_logic;
  signal sl_s_axis_tready                   : std_logic;

  signal sv_m_axis_tdata                    : std_logic_vector(3*GI_PIXEL_WIDTH -1 downto 0);
  signal sv_m_axis_tdatad1                  : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal sl_m_axis_tlast                    : std_logic;
  signal sl_m_axis_tvalid                   : std_logic;
  signal sl_m_axis_tvalidd1                 : std_logic;
  signal sl_m_axis_tready                   : std_logic;

  signal sl_simulation_done                 : std_logic := '0';
  signal sl_end_simulation                  : std_logic := '0';
  signal sl_error                           : std_logic := '0';
  signal sl_error_hold                      : std_logic := '0';
  signal su_error_counter                   : unsigned(CI_NUM_OF_PIXELS_BITS -1 downto 0);

  signal sv_rd_img_tdata                    : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal sl_rd_img_tlast                    : std_logic;
  signal sl_rd_img_tvalid                   : std_logic;
  signal sl_rd_img_tready                   : std_logic;

  signal sl_frame_start                     : std_logic;
  signal sl_eof                             : std_logic := '0';

  constant  cs_file_in_name                 : string  := gs_IMAGE_input;

  signal  dbg_tdata                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal  dbg_tuser                         : std_logic;
  signal  dbg_tlast                         : std_logic;
  signal  dbg_tvalid                        : std_logic;
  signal  dbg_tready                        : std_logic;

  signal  pixin_tdata                       : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal  pixin_tuser                       : std_logic;
  signal  pixin_tlast                       : std_logic;
  signal  pixin_tvalid                      : std_logic;
  signal  pixin_tready                      : std_logic;

  signal  pixin_tvalid_rnd                  : std_logic;
  signal  pixin_tready_rnd                  : std_logic;
  signal  pixout_tvalid_rnd                 : std_logic;
  signal  pixout_tready_rnd                 : std_logic;
  signal  rnd_cnt                           : unsigned(4 downto 0);
  signal  rnd_sft                           : std_logic_vector(4 downto 0);
  signal  rnd_out                           : std_logic;
  
  signal  pixout                            : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  
  constant C_ZERO                           : std_logic_vector(3 downto 0) := x"0";
  
  constant C_USE_REAL_IMAGE                 : std_logic := '1';
  constant C_RND_EN                         : std_logic := '0'; --1

begin

------------------------------------------------------------------------------
-- Clock and Reset
------------------------------------------------------------------------------
  sl_rst          <= '1' after  100 ns;
  --sl_clk          <= '0' when (sl_end_simulation = '1') else not sl_clk after clock_period; --ns  
  sl_clk          <= not sl_clk after clock_period/2 ;  

------------------------
-- Test bench control --
------------------------
  process begin
    -- trigger frame start
    wait until rising_edge(sl_clk) and sl_rst='1' ;
    sl_frame_start <= '1';
    wait until rising_edge(sl_clk) and sl_rst='1';
    sl_frame_start <= '0';
    wait until sl_eof = '1';  -- wait until end of file
    wait for 1 ms;
    wait until rising_edge(sl_clk);
    assert false report "simulation finished !" severity failure;

  end process;

------------------------------------------------------
-- READ REAL IMAGE DATA
------------------------------------------------------
u_rd_file_axis: entity work.rd_file_axis
  generic map (
    gs_filename            => cs_file_in_name,
    GI_PIXEL_WIDTH         => GI_PIXEL_WIDTH)
  port map (
    il_clk                 => sl_clk,
    il_rst                 => sl_rst,
    ol_eof                 => sl_eof,

    il_frame_start         => sl_frame_start,
    
    ov_m_axis_tdata        => sv_rd_img_tdata,
    ol_m_axis_tlast        => sl_rd_img_tlast,
    ol_m_axis_tvalid       => sl_rd_img_tvalid,
    il_m_axis_tready       => sl_rd_img_tready
  );



------------------------------------------------------
-- GENERATE INCREMENTAL DEBUG DATA
------------------------------------------------------

------------------------------------------------------
-- READY / VALID RANDOMIZER
------------------------------------------------------
process (sl_clk) begin
    if (rising_edge(sl_clk)) then
      if (sl_rst = '0') then
        rnd_cnt <= (0 => '1', others => '0');
        rnd_sft <= (0 => '1', others => '0');
      else
        rnd_cnt <= rnd_cnt + 1;
        rnd_sft <= rnd_sft(0) & rnd_sft(rnd_sft'length-1 downto 1);
      end if;
    end if;
  end process;
  rnd_out <= not(C_RND_EN) when (( or(rnd_sft and std_logic_vector(rnd_cnt(rnd_sft'length-1 downto 0)))) ) else '1';

  pixin_tready_rnd  <= pixin_tready and rnd_out;

------------------------------------------------------
  -- USE REAL IMAGE?
  ------------------------------------------------------
  pixin_tdata   <= sv_rd_img_tdata  when (C_USE_REAL_IMAGE = '1') else dbg_tdata;
  pixin_tlast   <= sl_rd_img_tlast  when (C_USE_REAL_IMAGE = '1') else dbg_tlast;
  pixin_tvalid  <= sl_rd_img_tvalid when (C_USE_REAL_IMAGE = '1') else dbg_tvalid;

  sl_rd_img_tready <= pixin_tready_rnd  when (C_USE_REAL_IMAGE = '1') else '0';

------------------------------------------------------------------------------
-- Module Under Test
------------------------------------------------------------------------------
  u_demosaicing: entity work.demosaicing
  generic map(
    GI_MASK_SIZE       => 5,
    GI_PIXEL_WIDTH     => GI_PIXEL_WIDTH,
    GI_IMG_HEIGHT      => GI_IMG_HEIGHT,
    GI_IMG_WIDTH       => GI_IMG_WIDTH)
  port map(
    il_clk             => sl_clk,                     
    il_rst             => sl_rst,                     

-- Pixels in mosaic
    iv_s_axis_tdata    => sv_rd_img_tdata,             
    il_s_axis_tlast    => sl_rd_img_tlast,              
    il_s_axis_tvalid   => sl_rd_img_tvalid,             
    ol_s_axis_tready   => pixin_tready,     

-- Pixels out as RGB8 
    ov_m_axis_tdata    => sv_m_axis_tdata,          
    ol_m_axis_tlast    => sl_m_axis_tlast,          
    ol_m_axis_tvalid   => sl_m_axis_tvalid,           
    il_m_axis_tready   => '1'); 

-------------------------
-- Capture output data --
-------------------------
---------------------------------------------------------------
--- Comparing and counting the errors
----------------------------------------------------------------
u_module_testbench: entity work.module_testbench
  generic map (
    gs_IMAGE_output_file_name     => gs_rtl_output,
    gs_IMAGE_output_expected      => gs_IMAGE_expected_output,
    GI_PIXEL_WIDTH                => GI_PIXEL_WIDTH)
  port map (
    il_clk                        => sl_clk,
    il_rst                        => sl_rst,
    
    iv_s_axis_tdata               => sv_m_axis_tdata,
    il_s_axis_tlast               => sl_m_axis_tlast,
    il_s_axis_tvalid              => sl_m_axis_tvalid,
    --ol_s_axis_tready       => sl_rd_img_tready,

    --ol_end_simulation      => sl_end_simulation,
    ol_error                      => sl_error
    --ol_error_hold          => sl_error_hold
  );

END;
