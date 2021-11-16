library IEEE;
use ieee.math_real.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spn_filter_axis_ctrl is
generic( 
  constant G_PIXEL_DEPTH         : integer := 16; --16
  constant G_IMG_WIDTH           : integer := 128;
  constant G_IMG_HEIGHT          : integer := 32;
  constant G_IMG_WIDTH_NUM_BITS  : integer := 7;
  constant G_IMG_HEIGHT_NUM_BITS : integer := 5
);
Port ( 
-- system signals
  il_clk                         : in  std_logic;
  il_rst                         : in  std_logic;

-- Pixels in as Mono 16
  iv_s_axis_tdata                : in  std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  il_s_axis_tlast                : in  std_logic;
  il_s_axis_tvalid               : in  std_logic;
  ol_s_axis_tready               : out std_logic;

--
  ov_ctrl_row_addr               : out std_logic_vector(G_IMG_HEIGHT_NUM_BITS -1 downto 0);
  ov_ctrl_col_addr               : out std_logic_vector(G_IMG_WIDTH_NUM_BITS -1 downto 0);
  ov_ctrl_tdata                  : out std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  ol_ctrl_tlast                  : out std_logic;
  ol_ctrl_tvalid                 : out std_logic;

  iv_data_sorter                 : in  std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  il_vld_sorter                  : in  std_logic;

  -- Pixels in as Mono 16
  ov_m_axis_tdata                : out std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
  ol_m_axis_tlast                : out std_logic;
  ol_m_axis_tvalid               : out std_logic;
  il_m_axis_tready               : in  std_logic

);
end spn_filter_axis_ctrl;

architecture Behavior of spn_filter_axis_ctrl is

constant C_IMG_NUM_BITS          : integer := (G_IMG_WIDTH_NUM_BITS + G_IMG_HEIGHT_NUM_BITS);
constant C_CNT_DOWN_BITS         : integer := integer(ceil(log2(real(G_IMG_WIDTH +6)))); --1 line or total num of cols + 5 clocks sorter

signal sv_s_axis_tdata_reg       : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
signal sl_s_axis_tlast_reg       : std_logic;

signal sl_s_ready                : std_logic;
signal sl_count_pixels_in        : std_logic;
signal su_pixin_cnt              : unsigned(C_IMG_NUM_BITS -1 downto 0);
signal su_pixout_cnt             : unsigned(C_IMG_NUM_BITS -1 downto 0);
signal su_pixout_cnt2             : unsigned(C_IMG_NUM_BITS -1 downto 0);

signal sl_sof                    : std_logic;
signal sl_eof                    : std_logic;
signal sl_eol                    : std_logic;

signal su_cont_col               : unsigned(G_IMG_WIDTH_NUM_BITS -1 downto 0);
signal su_cont_row               : unsigned(G_IMG_HEIGHT_NUM_BITS -1 downto 0);

signal su_cont_col_d1            : unsigned(G_IMG_WIDTH_NUM_BITS -1 downto 0);
signal su_cont_row_d1            : unsigned(G_IMG_HEIGHT_NUM_BITS -1 downto 0);

signal sl_fifo_flush             : std_logic;
signal su_cont_down              : unsigned(C_CNT_DOWN_BITS -1 downto 0);
signal sl_vld                    : std_logic;
signal sl_rdy                    : std_logic;
signal sl_last                   : std_logic;

begin

-- SPN CONTROLLER to HANDLE AXIS and GEN ADDRESSES
--SLAVE iNTERFACE
sl_s_ready                 <= il_rst;
ol_s_axis_tready           <= sl_s_ready;
sl_count_pixels_in         <= sl_s_ready and il_s_axis_tvalid;

process(il_clk)
begin
  if rising_edge(il_clk) then
    ol_ctrl_tvalid <= sl_count_pixels_in;  
  end if;
end process;


reg_data: process(il_clk)
begin
  if rising_edge(il_clk) then
     if (sl_count_pixels_in = '1') then
      sv_s_axis_tdata_reg   <= iv_s_axis_tdata;
      sl_s_axis_tlast_reg   <= il_s_axis_tlast;
     else
      sv_s_axis_tdata_reg   <= sv_s_axis_tdata_reg; --hold the data
      sl_s_axis_tlast_reg   <=  '0';
     end if;
  end if;
end process reg_data;

ov_ctrl_tdata            <= sv_s_axis_tdata_reg;
ol_ctrl_tlast            <= sl_s_axis_tlast_reg;

-- after I reach ol_ctrl_tlast 1 I count 1 line + 5 til find 0,0 , if it does not find 0,0 it means it is the last frame
-- flushing out the fifo for the last frame
process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_cont_down  <= (others => '0'); 
    elsif (sl_s_axis_tlast_reg = '1')  then --start counting down
      su_cont_down  <= to_unsigned(G_IMG_WIDTH +6, C_CNT_DOWN_BITS);
    elsif (su_cont_col_d1 = 0 and su_cont_row_d1 = 0) then
      su_cont_down  <= (others => '0');
    elsif (su_cont_down  > 0) then
      su_cont_down  <= su_cont_down  -1;
    end if;  
  end if;
end process;

sl_fifo_flush <= '1' when (su_cont_down  > 0) else '0';

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_pixout_cnt <= (others=>'0');  
    elsif (su_pixin_cnt = (G_IMG_WIDTH + 5 +1)) then
      su_pixout_cnt <= to_unsigned(G_IMG_WIDTH*G_IMG_HEIGHT , C_IMG_NUM_BITS);
    elsif (il_m_axis_tready = '1' and su_pixout_cnt > 0) then
      su_pixout_cnt <= su_pixout_cnt -1;
    elsif (il_m_axis_tready = '0') then
      su_pixout_cnt <= (others=>'0'); 
    end if;  
  end if;
end process;

sl_rdy <= '1' when (su_pixout_cnt > 0) else '0';

ol_m_axis_tvalid <= sl_rdy or sl_fifo_flush;
ov_m_axis_tdata  <= iv_data_sorter;

-- generating the tlast out
process(il_clk)
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_pixout_cnt2 <= (others=>'0');
    elsif (sl_last = '1') then
      su_pixout_cnt2 <= (others=>'0');
    elsif (sl_rdy = '1' or sl_fifo_flush = '1') then
      su_pixout_cnt2 <= su_pixout_cnt2 +1;
    end if;
  end if;
end process;

sl_last <= '1' when (su_pixout_cnt2 = (G_IMG_WIDTH*G_IMG_HEIGHT -1)) else '0';
ol_m_axis_tlast <= sl_last;
-- pixin_cnt
process (il_clk) 
begin
   if (rising_edge(il_clk)) then
    if (il_rst = '0') then
      su_pixin_cnt <= (others => '0'); 
    elsif (sl_eof = '1') then
      su_pixin_cnt <= (others => '0');
    elsif (sl_count_pixels_in = '1') then 
      su_pixin_cnt <= su_pixin_cnt + 1;
    end if;
  end if;
end process;

sl_sof  <= '1' when (sl_count_pixels_in = '1' and su_pixin_cnt = 0) else '0';   
sl_eof  <= '1' when (sl_count_pixels_in = '1' and su_pixin_cnt = (G_IMG_WIDTH*G_IMG_HEIGHT -1)) else '0';     

process (il_clk) 
begin
   if (rising_edge(il_clk)) then
    if (il_rst = '0') then
      su_cont_col <= (others => '0');
    elsif (sl_eol  = '1') then
      su_cont_col <= (others => '0');
    elsif (sl_count_pixels_in = '1') then 
      su_cont_col <=su_cont_col + 1;
    end if;
   end if;
end process;

sl_eol  <= '1' when (su_cont_col = G_IMG_WIDTH -1)  else '0';

process (il_clk) 
begin
  if rising_edge(il_clk) then
    if (il_rst = '0') then
      su_cont_row <= (others => '0');  
    elsif (sl_eof = '1') then  
      su_cont_row <= (others => '0');
    elsif (sl_count_pixels_in = '1' and sl_eol = '1') then 
      su_cont_row <= su_cont_row +1;
    end if;
  end if;
end process;

process(il_clk)
begin
  if rising_edge(il_clk) then
    if (su_cont_row = 0) then
      su_cont_row_d1 <= to_unsigned(G_IMG_HEIGHT -1, G_IMG_HEIGHT_NUM_BITS) ; -- correcting the valid row
    else
      su_cont_row_d1 <= su_cont_row -1;  
    end if;
    su_cont_col_d1 <= su_cont_col; 
  end if;
end process;

ov_ctrl_col_addr                <= std_logic_vector(su_cont_col_d1); 
ov_ctrl_row_addr                <= std_logic_vector(su_cont_row_d1);

end Behavior;