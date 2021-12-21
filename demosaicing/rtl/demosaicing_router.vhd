
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.comm_types_pkg.all;

entity demosaicing_router is
generic( 
  constant GI_MASK_SIZE          : integer := 3;
  constant GI_PIXEL_WIDTH        : integer := 16; 
  constant GI_IMG_HEIGHT         : integer := 8; 
  constant GI_IMG_WIDTH          : integer := 8;
  constant GI_COL_NUM_BITS       : integer := 8;
  constant GI_ROW_NUM_BITS       : integer := 8
);
Port ( 
-- system signals
  il_clk                         : in  std_logic;
  il_rst                         : in  std_logic;

  iv_col_addr                    : in std_logic_vector(GI_COL_NUM_BITS -1 downto 0);
  iv_row_addr                    : in std_logic_vector(GI_ROW_NUM_BITS -1 downto 0);
  
  ivn_mask                       : in  std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0);
  ov_bgbgrr_code                 : out BAYER_PATTERN_TYPE;
  ovn_mask                       : out std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0)
);
end demosaicing_router;

architecture Behavioral of demosaicing_router is

TYPE BAYER_MASK is (red, gr, gb, blu);
signal pix_bayer_pos : BAYER_MASK;

signal sl_r                      : std_logic;
signal sl_gr                     : std_logic;
signal sl_gb                     : std_logic;
signal sl_b                      : std_logic;

signal sv_code                   : std_logic_vector(3 downto 0);

begin

sl_r    <= '1' when (iv_col_addr(0) = '0' and iv_row_addr(0) = '0') else '0';
sl_gr   <= '1' when (iv_col_addr(0) = '1' and iv_row_addr(0) = '0') else '0';
sl_gb   <= '1' when (iv_col_addr(0) = '0' and iv_row_addr(0) = '1') else '0';
sl_b    <= '1' when (iv_col_addr(0) = '1' and iv_row_addr(0) = '1') else '0';

sv_code <= sl_b & sl_gb & sl_gr & sl_r;

process(il_clk)
begin
  if rising_edge(il_clk) then
    if ((unsigned(iv_row_addr) > 1) and (unsigned(iv_row_addr) < GI_IMG_HEIGHT -2) and
    (unsigned(iv_col_addr) > 1) and (unsigned(iv_col_addr) < GI_IMG_WIDTH -0)) then -- original < col -0
       -- center 
       ovn_mask        <= ivn_mask;
       ov_bgbgrr_code  <= sv_code;
    else
       -- padding
       ov_bgbgrr_code  <= (others=>'0');
       ovn_mask        <= (others=>(others => '0'));
    end if;
    
  end if;
end process;

end Behavioral;
