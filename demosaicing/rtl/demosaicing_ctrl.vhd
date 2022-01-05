library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
--use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity demosaicing_ctrl is
generic( 
  constant GI_MASK_SIZE          : integer := 5;
  constant GI_PIXEL_WIDTH        : integer := 16; 
  constant GI_IMG_HEIGHT         : integer := 8; 
  constant GI_IMG_WIDTH          : integer := 8;
  constant GI_HEIGHT_NUM_BITS    : integer := 8; 
  constant GI_WIDTH_NUM_BITS     : integer := 8
  
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

-- INF FIFO5
  ov_pixel                       : out std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  ov_col_addr                    : out std_logic_vector(GI_WIDTH_NUM_BITS -1 downto 0);
  ov_row_addr                    : out std_logic_vector(GI_HEIGHT_NUM_BITS -1 downto 0);

  ol_m_axis_tlast                : out std_logic;
  ol_m_axis_tvalid               : out std_logic;
  il_m_axis_tready               : in  std_logic
  
);
end demosaicing_ctrl;

architecture Behavioral of demosaicing_ctrl is

constant CI_IMG_NUM_BITS         : integer := integer(ceil(log2(real(GI_IMG_WIDTH*GI_IMG_HEIGHT))));

signal sv_s_tdata_reg            : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
signal sl_s_tlast_reg            : std_logic;

signal su_col_cnt                : unsigned(GI_WIDTH_NUM_BITS -1 downto 0);
signal su_row_cnt                : unsigned(GI_HEIGHT_NUM_BITS -1 downto 0);

signal su_col_out_cnt            : unsigned(GI_WIDTH_NUM_BITS -1 downto 0);
signal su_row_out_cnt            : unsigned(GI_HEIGHT_NUM_BITS -1 downto 0);
signal su_pix_out_cnt            : unsigned(CI_IMG_NUM_BITS -1 downto 0);

signal su_col_cntd               : unsigned(GI_WIDTH_NUM_BITS -1 downto 0);
signal su_row_cntd               : unsigned(GI_HEIGHT_NUM_BITS -1 downto 0);

signal sl_pixin_cnt_en           : std_logic;

signal sl_eil                    : std_logic; -- end of input line
signal sl_eif                    : std_logic; -- end of input frame
signal sl_sif                    : std_logic; -- start of input frame

signal sl_eol                    : std_logic; 
signal sl_sof                    : std_logic; -- start of output frame
signal sl_eof                    : std_logic := '0';
signal sl_last_pix               : std_logic;
signal sl_valid_fifo             : std_logic; -- start of output frame
signal sl_valid_fifo_c0          : std_logic; -- 
signal sl_valid_fifo_c1          : std_logic;
signal sl_valid_fifo_c2          : std_logic;
signal sl_valid_fifo_c3          : std_logic;
signal sl_valid_fifo_c4          : std_logic; -- 
signal sl_valid_fifo_c5          : std_logic;
signal sl_valid_fifo_c6          : std_logic;
signal sl_valid_demosaic         : std_logic; -- start of output frame

signal sl_s_ready                : std_logic;

begin

-- SPN CONTROLLER to HANDLE AXIS and GEN ADDRESSES
-- SLAVE iNTERFACE
ol_s_axis_tready                 <= sl_s_ready;
sl_s_ready                       <= il_rst;
sl_pixin_cnt_en                  <= sl_s_ready and il_s_axis_tvalid;

ov_pixel                         <= iv_s_axis_tdata;

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (sl_pixin_cnt_en = '1') then
      sv_s_tdata_reg <= iv_s_axis_tdata;
      sl_s_tlast_reg <= il_s_axis_tlast;
    else
      sv_s_tdata_reg <= sv_s_tdata_reg;
      sl_s_tlast_reg <= '0';
    end if;
  end if;
end process;

-- COUNT COLS
process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_col_cnt <= (others => '0'); 
    elsif (sl_eil = '1') then
      su_col_cnt <= (others => '0'); 
    elsif (sl_pixin_cnt_en = '1') then 
      su_col_cnt <= su_col_cnt + 1;
    end if;
    su_col_cntd <= su_col_cnt;
  end if;
end process;

sl_eil  <= '1' when (sl_pixin_cnt_en = '1' and su_col_cnt = (GI_IMG_WIDTH -1)) else '0'; 

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_row_cnt <= (others => '0'); 
    elsif (sl_eif = '1') then
      su_row_cnt <= (others => '0'); 
    elsif (sl_pixin_cnt_en = '1' and sl_eil='1') then 
      su_row_cnt <= su_row_cnt + 1;
    end if;
    su_row_cntd <= su_row_cnt;
  end if;
end process; 

sl_eif <= '1' when (sl_pixin_cnt_en = '1' and (il_s_axis_tlast = '1' or su_row_cnt = (GI_IMG_HEIGHT ))) else '0';

-- started in the half of the filter GI_MASK_SIZE -1,  prev-3 
-- INITIALLY I SET 0 for su_col_cnt 2 -3
sl_sof <= '1' when (su_col_cnt = (2) and su_row_cnt = (GI_MASK_SIZE -3)) else '0';

process (il_clk)
begin 
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      sl_valid_fifo <= '0';
    elsif (sl_sof = '1') then
      sl_valid_fifo <= '1';
    elsif (sl_eof = '1') then
      sl_valid_fifo <= '0';
    end if;
  end if;
end process;

process (il_clk)
begin 
  if rising_edge(il_clk) then
    sl_valid_fifo_c0  <= sl_valid_fifo;
    sl_valid_fifo_c1  <= sl_valid_fifo_c0;
    sl_valid_fifo_c2  <= sl_valid_fifo_c1;
    sl_valid_fifo_c3  <= sl_valid_fifo_c2;
    sl_valid_fifo_c4  <= sl_valid_fifo_c3;
    sl_valid_fifo_c5  <= sl_valid_fifo_c4;
    sl_valid_fifo_c6  <= sl_valid_fifo_c5;
  end if;
end process;

--sl_valid_demosaic     <= sl_valid_fifo_c3; 
  sl_valid_demosaic   <= sl_valid_fifo_c6;

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_pix_out_cnt <= (others => '0');
    elsif (sl_last_pix = '1') then
      su_pix_out_cnt <= (others => '0');
    elsif (sl_sof = '1') then
      su_pix_out_cnt <= (others => '0');
    elsif (sl_valid_demosaic = '1') then
      su_pix_out_cnt <= su_pix_out_cnt +1; 
    end if;
  end if;
end process;

sl_last_pix          <= '1' when (su_pix_out_cnt=GI_IMG_WIDTH*GI_IMG_HEIGHT-1) else '0';
ol_m_axis_tlast      <= sl_last_pix;
ol_m_axis_tvalid     <= sl_valid_demosaic;

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_col_out_cnt <= (others => '0');
    elsif (sl_eol = '1') then
      su_col_out_cnt <= (others => '0');
    elsif (sl_valid_fifo = '1') then  
      su_col_out_cnt <= su_col_out_cnt +1; 
    end if;
  end if;
end process;
                                                                             -- -1
sl_eol      <= '1' when (sl_valid_fifo = '1' and su_col_out_cnt = (GI_IMG_WIDTH -1)) else '0'; 

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_row_out_cnt <= (others => '0');
    elsif (sl_eof = '1') then
      su_row_out_cnt <= (others => '0');
    elsif (sl_valid_fifo = '1' and sl_eol = '1') then
      su_row_out_cnt <= su_row_out_cnt +1;      
    end if;
  end if;
end process;
                                                                                   
sl_eof      <= '1' when (su_col_out_cnt = (GI_IMG_WIDTH -1) and (su_row_out_cnt = (GI_IMG_HEIGHT -1))) else '0';

ov_col_addr <= std_logic_vector(su_col_out_cnt);
ov_row_addr <= std_logic_vector(su_row_out_cnt);

end Behavioral;
