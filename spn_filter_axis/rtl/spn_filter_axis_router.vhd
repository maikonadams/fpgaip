library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity spn_filter_axis_router is
generic(
  constant G_PIXEL_DEPTH   : integer := 16;
  constant G_COL_NUM_BITS  : integer := 7;
  constant G_ROW_NUM_BITS  : integer := 5;
  constant G_IMG_WIDTH     : integer := 128;
  constant G_IMG_HEIGHT    : integer := 32 
);
Port(
-- system signals
  il_clk                   : in  std_logic;
  il_rst                   : in  std_logic;

  ol_router_rdy            : out std_logic;

  iv_row                   : in  STD_LOGIC_VECTOR (G_ROW_NUM_BITS - 1 downto 0);
  iv_col                   : in  STD_LOGIC_VECTOR (G_COL_NUM_BITS - 1 downto 0);

  iv_yija                  : in  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  iv_yi_1jp1b              : in  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  iv_yi_1jc                : in  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  iv_yi_1j_1d              : in  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  iv_yi_2je                : in  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
           
  ov_oa                    : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  ov_ob                    : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  ov_oc                    : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  ov_od                    : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0);
  ov_oe                    : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH - 1 downto 0));
end spn_filter_axis_router;

architecture Behavioral of spn_filter_axis_router is

signal sl_firstRow         : std_logic;
signal sl_firstCol         : std_logic;
signal sl_lastRow          : std_logic;
signal sl_lastCol          : std_logic;

signal sv_code             : std_logic_vector(3 downto 0);

TYPE STATE_TYPE IS (clt, crt, clb, crb, bt, bb, bl, br, mid, iddle); --clt - corner left top , corner right 
SIGNAL state               : STATE_TYPE;

signal sv_row_reg          : STD_LOGIC_VECTOR (G_ROW_NUM_BITS - 1 downto 0);
signal sv_col_reg          : STD_LOGIC_VECTOR (G_COL_NUM_BITS - 1 downto 0);

signal sl_full_1st_line    : std_logic;

begin

--sl_firstRow <= '1' when unsigned(iv_row) = 0 else '0';
--sl_firstCol <= '1' when unsigned(iv_col) = 0 else '0';
--sl_lastRow  <= '1' when unsigned(iv_row) = (G_IMG_HEIGHT -1) else '0';
--sl_lastCol  <= '1' when unsigned(iv_col) = (G_IMG_WIDTH -1) else '0';

process(il_clk)
begin
  if (rising_edge(il_clk)) then
    sv_row_reg <= iv_row;
    sv_col_reg <= iv_col; 
  end if;
end process;

process(il_clk)
begin
  if (rising_edge(il_clk)) then
    if (il_rst='0') then
      sl_full_1st_line <= '0';
    elsif (sl_full_1st_line = '0' and sl_firstRow = '1' and sl_firstCol = '1') then
      sl_full_1st_line <= '1';
    --elsif (state = crb) then
      --sl_full_1st_line <= '0';
    else 
      sl_full_1st_line <= '0';
    end if; 
  end if;
end process;
ol_router_rdy <= sl_full_1st_line;

sl_firstRow <= '1' when unsigned(sv_row_reg) = 0 else '0';
sl_firstCol <= '1' when unsigned(sv_col_reg) = 0 else '0';
sl_lastRow  <= '1' when unsigned(sv_row_reg) = (G_IMG_HEIGHT -1) else '0';
sl_lastCol  <= '1' when unsigned(sv_col_reg) = (G_IMG_WIDTH -1) else '0';

sv_code <= sl_firstRow & sl_lastRow & sl_firstCol & sl_lastCol;

router:process(iv_yija, iv_yi_1jp1b, iv_yi_1jc, iv_yi_1j_1d, iv_yi_2je, sv_code )
begin
  case sv_code is
    when "1010" =>
	           state <= clt;
		   ov_oa <= iv_yija;
	           ov_ob <= iv_yi_1jp1b;
	           ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yija; 
		   ov_oe <= iv_yi_1jp1b; 

    when "1000" | "0100" =>
		   state <= bt;
	           ov_oa <= iv_yi_1jp1b;
		   ov_ob <= iv_yi_1jp1b;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_1j_1d; 
	           ov_oe <= iv_yi_1j_1d;

    when "1001" =>
		   state <= crt;
		   ov_oa <= iv_yija;
		   ov_ob <= iv_yija;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_1j_1d; 
		   ov_oe <= iv_yi_1j_1d;

    when "0010" | "0001" =>
		   state <= bl;
		   ov_oa <= iv_yija;
		   ov_ob <= iv_yija;
		   ov_oc <= iv_yi_1jc; 
	           ov_od <= iv_yi_2je; 
		   ov_oe <= iv_yi_2je;

    when "0110" =>
		   state <= clb;
		   ov_oa <= iv_yi_1jp1b;
	           ov_ob <= iv_yi_1jp1b;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_2je; 
		   ov_oe <= iv_yi_2je;

    when "0101" =>
		   state <= crb;
		   ov_oa <= iv_yi_1j_1d;
		   ov_ob <= iv_yi_2je;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_1j_1d; 
		   ov_oe <= iv_yi_2je;

    when "0000" =>
		   state <= mid;
		   ov_oa <= iv_yija;
		   ov_ob <= iv_yi_1jp1b;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_1j_1d; 
		   ov_oe <= iv_yi_2je;

    when others => 
		   state <= mid;
		   ov_oa <= iv_yija;
		   ov_ob <= iv_yi_1jp1b;
		   ov_oc <= iv_yi_1jc; 
		   ov_od <= iv_yi_1j_1d; 
		   ov_oe <= iv_yi_2je;

end case;
end process router;

end Behavioral;


