
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

use work.comm_types_pkg.all;

entity demosaicing is
generic( 
  constant GI_MASK_SIZE          : integer := 3;
  constant GI_PIXEL_WIDTH        : integer := 16; 
  constant GI_IMG_HEIGHT         : integer := 8; 
  constant GI_IMG_WIDTH          : integer := 8 -- 8x8 and 8*2 ... memory is from 0 .. to 16= 17elements
);
Port ( 
-- system signals
  il_clk                         : in  std_logic;
  il_rst                         : in  std_logic;

  -- Pixels in mosaic
  iv_s_axis_tdata                : in  std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  il_s_axis_tlast                : in  std_logic;
  il_s_axis_tvalid               : in  std_logic;
  ol_s_axis_tready               : out std_logic;

-- Pixels out as RGB8 
  ov_m_axis_tdata                : out std_logic_vector(3*GI_PIXEL_WIDTH -1 downto 0);
  ol_m_axis_tlast                : out std_logic;
  ol_m_axis_tvalid               : out std_logic;
  il_m_axis_tready               : in  std_logic
);
end demosaicing;

architecture Behavioral of demosaicing is

constant CI_WIDTH_NUM_BITS       : integer := integer(ceil(log2(real(GI_IMG_WIDTH))));
constant CI_HEIGHT_NUM_BITS      : integer := integer(ceil(log2(real(GI_IMG_HEIGHT))));

signal sv_pixel2fifo5            : STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);
signal sv_col_addr               : std_logic_vector(CI_WIDTH_NUM_BITS -1 downto 0);
signal sv_row_addr               : std_logic_vector(CI_HEIGHT_NUM_BITS -1 downto 0);
signal svn_mask                  : std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0);
signal svn_mask_fromRouter       : std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0);
signal sv_rggb_code              : std_logic_vector(3 downto 0);

signal  sv_r                     : STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);
signal  sv_g                     : STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);
signal  sv_b                     : STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);

begin

  u_demosaicing_ctrl: entity work.demosaicing_ctrl
  generic map(
    GI_MASK_SIZE       => GI_MASK_SIZE,
    GI_PIXEL_WIDTH     => GI_PIXEL_WIDTH,
    GI_IMG_HEIGHT      => GI_IMG_HEIGHT,
    GI_IMG_WIDTH       => GI_IMG_WIDTH,
    GI_HEIGHT_NUM_BITS => CI_HEIGHT_NUM_BITS,
    GI_WIDTH_NUM_BITS  => CI_WIDTH_NUM_BITS)
  port map(
    il_clk             => il_clk,                     
    il_rst             => il_rst,                     

-- Pixels in mosaic
    iv_s_axis_tdata    => iv_s_axis_tdata,             
    il_s_axis_tlast    => il_s_axis_tlast,              
    il_s_axis_tvalid   => il_s_axis_tvalid,             
    ol_s_axis_tready   => ol_s_axis_tready, 

-- INF w FIFO5          
    ov_pixel           => sv_pixel2fifo5,
    ov_col_addr        => sv_col_addr,
    ov_row_addr        => sv_row_addr, 

-- Pixels out as RGB8              
    ol_m_axis_tlast    => ol_m_axis_tlast,          
    ol_m_axis_tvalid   => ol_m_axis_tvalid,           
    il_m_axis_tready   => il_m_axis_tready); 

  u_demosaicing_fifo5: entity work.demosaicing_fifo5 
  generic  map( 
    GI_MASK_SIZE       => GI_MASK_SIZE,      
    GI_PIXEL_DEPTH     => GI_PIXEL_WIDTH,     
    GI_IMG_HEIGHT      => GI_IMG_HEIGHT,      
    GI_IMG_WIDTH       => GI_IMG_WIDTH)
  Port map ( 
    il_clk             => il_clk,
    il_rst             => il_rst,

    il_move            => '1',
    iv_pixel           => sv_pixel2fifo5,

    ovn_mask           => svn_mask);

  u_demosaicing_router: entity work.demosaicing_router
  generic map( 
    GI_MASK_SIZE       => GI_MASK_SIZE,
    GI_PIXEL_WIDTH     => GI_PIXEL_WIDTH,
    GI_IMG_HEIGHT      => GI_IMG_HEIGHT,
    GI_IMG_WIDTH       => GI_IMG_WIDTH,
    GI_COL_NUM_BITS    => CI_WIDTH_NUM_BITS,
    GI_ROW_NUM_BITS    => CI_HEIGHT_NUM_BITS)
  Port map ( 
  -- system signals
    il_clk             => il_clk,
    il_rst             => il_rst,

    iv_col_addr        => sv_col_addr,
    iv_row_addr        => sv_row_addr,
    ivn_mask           => svn_mask,

    ov_bgbgrr_code     => sv_rggb_code,
    ovn_mask           => svn_mask_fromRouter);

  u_demosaicing_conv: entity work.demosaicing_convolution
  generic map( 
    GI_MASK_SIZE       => GI_MASK_SIZE,
    GI_PIXEL_WIDTH     => GI_PIXEL_WIDTH,
    GI_IMG_HEIGHT      => GI_IMG_HEIGHT,
    GI_IMG_WIDTH       => GI_IMG_WIDTH)
  Port map ( 
  -- system signals
    il_clk             => il_clk,
    il_rst             => il_rst,

    il_vld             => '1', 
    iv_bgbgrr_code     => sv_rggb_code,
    ivn_mask           => svn_mask_fromRouter,
  
    ov_r               => sv_r,
    ov_g               => sv_g,
    ov_b               => sv_b
    );

  ov_m_axis_tdata(GI_PIXEL_WIDTH -1 downto 0)                  <= sv_r;
  ov_m_axis_tdata(2*GI_PIXEL_WIDTH -1 downto GI_PIXEL_WIDTH)   <= sv_g;
  ov_m_axis_tdata(3*GI_PIXEL_WIDTH -1 downto 2*GI_PIXEL_WIDTH) <= sv_b;

end Behavioral;

