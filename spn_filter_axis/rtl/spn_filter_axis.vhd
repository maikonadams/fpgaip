library IEEE;
use ieee.math_real.all;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spn_filter_axis is
generic( 
  constant G_PIXEL_DEPTH        : integer := 16; 
  constant G_IMG_WIDTH          : integer := 128;
  constant G_IMG_HEIGHT         : integer := 32 
);
Port ( 
-- system signals
  il_clk                        : in  std_logic;
  il_rst                        : in  std_logic;

-- Pixels in as Mono 16
  iv_s_axis_tdata               : in  std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  il_s_axis_tlast               : in  std_logic;
  il_s_axis_tvalid              : in  std_logic;
  ol_s_axis_tready              : out std_logic;

-- Pixels out as Mono 16
  ov_m_axis_tdata               : out std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  ol_m_axis_tlast               : out std_logic;
  ol_m_axis_tvalid              : out std_logic;
  il_m_axis_tready              : in  std_logic

);
end spn_filter_axis;

architecture Behavior of spn_filter_axis is

constant C_IMG_WIDTH_NUM_BITS   : integer := integer(ceil(log2(real(G_IMG_WIDTH))));
constant C_IMG_HEIGHT_NUM_BITS  : integer := integer(ceil(log2(real(G_IMG_HEIGHT))));

signal sl_router_rdy            : std_logic;
signal sl_sorter_vld            : std_logic;
signal sl_sorter_rdy            : std_logic; 

signal sv_row_addr              : std_logic_vector(C_IMG_HEIGHT_NUM_BITS -1 downto 0);
signal sv_col_addr              : std_logic_vector(C_IMG_WIDTH_NUM_BITS -1 downto 0); 
signal sv_s_axis_tdata          : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
signal sl_s_axis_tlast          : std_logic; 
signal sl_s_axis_tvalid         : std_logic; 

signal sv_yij                   : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_1jp1               : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_1j                 : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_1j_1               : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_2j                 : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);

signal sv_oa                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_ob                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_oc                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_od                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_oe                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);

signal sv_median                : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);             

begin

-- SPN CONTROLLER to HANDLE AXIS and GEN ADDRESSES
------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
  spn_filter_axis_ctrl_inst : entity work.spn_filter_axis_ctrl
  generic map
  (
    G_PIXEL_DEPTH         => G_PIXEL_DEPTH,
    G_IMG_WIDTH           => G_IMG_WIDTH,       
    G_IMG_HEIGHT          => G_IMG_HEIGHT,
    G_IMG_WIDTH_NUM_BITS  => C_IMG_WIDTH_NUM_BITS,
    G_IMG_HEIGHT_NUM_BITS => C_IMG_HEIGHT_NUM_BITS
  )
  port map
  (
    il_clk                => il_clk,
    il_rst                => il_rst,
-------------------------------------------
----              AXIS S INF
------------------------------------------
    iv_s_axis_tdata       => iv_s_axis_tdata,
    il_s_axis_tlast       => il_s_axis_tlast,
    il_s_axis_tvalid      => il_s_axis_tvalid,
    ol_s_axis_tready      => ol_s_axis_tready,
-------------------------------------------
----                FIFO            
------------------------------------------
    ov_ctrl_tdata         => sv_s_axis_tdata,
    ol_ctrl_tlast         => sl_s_axis_tlast,
    ol_ctrl_tvalid        => sl_s_axis_tvalid,  
-------------------------------------------
----               Router            
------------------------------------------ 
    ov_ctrl_row_addr      => sv_row_addr,
    ov_ctrl_col_addr      => sv_col_addr,  
-------------------------------------------
----              Sorter 
------------------------------------------
    iv_data_sorter        => sv_median,
    il_vld_sorter         => sl_sorter_rdy,
-------------------------------------------
----              AXIS M INF
------------------------------------------
    ov_m_axis_tdata       => ov_m_axis_tdata,
    ol_m_axis_tlast       => ol_m_axis_tlast,       
    ol_m_axis_tvalid      => ol_m_axis_tvalid,
    il_m_axis_tready      => il_m_axis_tready  
  );

  spn_filter_axis_fifo_inst : entity work.spn_filter_axis_fifo
  generic map
  (
     G_PIXEL_DEPTH        => G_PIXEL_DEPTH,
     G_FIFO_SIZE          => G_IMG_WIDTH
  )
  port map
  (
     il_clk               => il_clk,
     il_rst               => il_rst,

     iv_yin               => sv_s_axis_tdata,
     ov_yij               => sv_yij,
     ov_yi_1jp1           => sv_yi_1jp1,
     ov_yi_1j             => sv_yi_1j,
     ov_yi_1j_1           => sv_yi_1j_1,
     ov_yi_2j             => sv_yi_2j
  );

  spn_filter_axis_router_inst : entity work.spn_filter_axis_router
  generic map
  (
     G_PIXEL_DEPTH        => G_PIXEL_DEPTH,
     G_COL_NUM_BITS       => C_IMG_WIDTH_NUM_BITS,
     G_ROW_NUM_BITS       => C_IMG_HEIGHT_NUM_BITS,
     G_IMG_WIDTH          => G_IMG_WIDTH,
     G_IMG_HEIGHT         => G_IMG_HEIGHT
  )
  port map
  (
     il_clk               => il_clk,
     il_rst               => il_rst,

     ol_router_rdy        => sl_router_rdy,
     
     iv_row               => sv_row_addr,
     iv_col               => sv_col_addr,

     iv_yija              => sv_yij,
     iv_yi_1jp1b          => sv_yi_1jp1,
     iv_yi_1jc            => sv_yi_1j,
     iv_yi_1j_1d          => sv_yi_1j_1,
     iv_yi_2je            => sv_yi_2j,
           
     ov_oa                => sv_oa,
     ov_ob                => sv_ob,
     ov_oc                => sv_oc,
     ov_od                => sv_od,
     ov_oe                => sv_oe
  );

  spn_filter_axis_sorter_inst : entity work.spn_filter_axis_sorter
  generic map
  (
     G_PIXEL_DEPTH        => G_PIXEL_DEPTH    
  )
  port map
  (
     il_clk               => il_clk,

     il_vld               => sl_router_rdy,           
     ol_rdy               => sl_sorter_rdy,
  
     iv_a                 => sv_oa,
     iv_b                 => sv_ob,
     iv_c                 => sv_oc,
     iv_d                 => sv_od,
     iv_e                 => sv_oe,

     ov_med               => sv_median
  );

  --ov_m_axis_tdata         <= sv_median;


end Behavior;
