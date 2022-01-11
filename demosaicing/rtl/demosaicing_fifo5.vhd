
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.comm_types_pkg.all;

entity demosaicing_fifo5 is
generic( 
  constant GS_RAM_STYLE          : string  := "block";  -- block/distributed/register
  constant GI_MASK_SIZE          : integer := 3;
  constant GI_PIXEL_DEPTH        : integer := 16; 
  constant GI_IMG_HEIGHT         : integer := 8; 
  constant GI_IMG_WIDTH          : integer := 8 -- 8x8 and 8*2 ... memory is from 0 .. to 16= 17elements
);
Port ( 
-- system signals
  il_clk                         : in  std_logic;
  il_rst                         : in  std_logic;

  il_move                        : in std_logic; -- coming from the Master input
  iv_pixel                       : in STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);

  ovn_mask                       : out std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0)
);
end demosaicing_fifo5;

architecture Behavioral of demosaicing_fifo5 is

constant CI_ADDR_LIM             : integer := (GI_IMG_WIDTH);
constant CI_TOTAL_NUM_PIX        : integer := (GI_IMG_WIDTH*GI_IMG_HEIGHT);
constant CI_ADDR_NUM_BITS        : integer := integer(ceil(log2(real(GI_IMG_WIDTH -1))));
constant GI_MASK_SIZE_SQ2        : integer := (GI_MASK_SIZE * GI_MASK_SIZE);

signal su_addr_wr                : unsigned(CI_ADDR_NUM_BITS -1 downto 0):= (others=>'0');
signal su_addr_rd                : unsigned(CI_ADDR_NUM_BITS -1 downto 0):= (others=>'0');

signal svn_mask_top              : std_logic_vector_xN(GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);
signal svn_mask                  : std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);

type FIFO_wRAM is array(0 to (GI_IMG_WIDTH -1) ) of std_logic_vector(GI_PIXEL_DEPTH -1 downto 0);
type MEM_ROWS  is array(0 to (GI_MASK_SIZE -1)) of FIFO_wRAM; 

type FIFO_wRAMv2 is array((GI_IMG_WIDTH -1) downto 0 ) of std_logic_vector(GI_PIXEL_DEPTH -1 downto 0);
signal fifo_row0                 : FIFO_wRAMv2;
signal fifo_row1                 : FIFO_wRAMv2;
signal fifo_row2                 : FIFO_wRAMv2;
signal fifo_row3                 : FIFO_wRAMv2;

signal fifo_rows                 : MEM_ROWS;
attribute ram_style              : string;
attribute ram_style of fifo_rows : signal is gs_ram_style;

attribute ram_style of fifo_row0 : signal is gs_ram_style;
attribute ram_style of fifo_row1 : signal is gs_ram_style;
attribute ram_style of fifo_row2 : signal is gs_ram_style;
attribute ram_style of fifo_row3 : signal is gs_ram_style;

begin

------------------------------------------------------------------------------
-- FIRST ROW
------------------------------------------------------------------------------
demosaicing_shiftreg_inst : entity work.demosaicing_shiftreg
generic map(
  GI_MASK_SIZE         => GI_MASK_SIZE,
  GI_PIXEL_DEPTH       => GI_PIXEL_DEPTH
)
port map(
    il_clk             => il_clk,
    il_wr              => il_move,
    iv_pixel           => iv_pixel,
    ovn_mask           => svn_mask_top
);

ovn_mask(24)           <= svn_mask_top(4);
ovn_mask(23)           <= svn_mask_top(3);
ovn_mask(22)           <= svn_mask_top(2);
ovn_mask(21)           <= svn_mask_top(1);
ovn_mask(20)           <= svn_mask_top(0);

------------------------------------------------------------------------------
-- SECOND ROW - fifo
------------------------------------------------------------------------------

update_address: process(il_clk)
begin
  if (rising_edge(il_clk)) then
    if (su_addr_wr < (CI_ADDR_LIM -1)) then
     -- if (il_wr='1') then
        su_addr_wr <= su_addr_wr +1;
        if (su_addr_rd = (CI_ADDR_LIM -1)) then
          su_addr_rd  <= (others => '0');
        else
          su_addr_rd  <= su_addr_rd + 1; 
        end if;
      --end if;
    else
      su_addr_wr <= (others => '0');
      su_addr_rd <= to_unsigned(1, su_addr_rd'length);
    end if;
  end if;
end process update_address;


process(il_clk)
begin
  if(rising_edge(il_clk)) then
   -- fifo_rows(0)(to_integer(su_addr_wr)) <= svn_mask_top(GI_MASK_SIZE -1); --iv_pixel
   -- svn_mask(19)                         <= fifo_rows(0)(to_integer(su_addr_rd));
    fifo_row0(to_integer(su_addr_wr)) <= svn_mask_top(GI_MASK_SIZE -1); --iv_pixel
    svn_mask(19)                         <= fifo_row0(to_integer(su_addr_rd));
  end if;
end process;

ovn_mask(19)                             <= svn_mask(19); --svn_mask_top(0);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(18) <= ovn_mask(19);
  --  end if;
  end if;
end process;

ovn_mask(18)       <= svn_mask(18);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(17) <= svn_mask(18);
  --  end if;
  end if;
end process;

ovn_mask(17)       <= svn_mask(17);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(16) <= svn_mask(17);
  --  end if;
  end if;
end process;

ovn_mask(16)       <= svn_mask(16);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(15) <= svn_mask(16);
  --  end if;
  end if;
end process;

ovn_mask(15)       <= svn_mask(15);

------------------------------------------------------------------------------
-- THIRD ROW
------------------------------------------------------------------------------
process(il_clk)
begin
  if(rising_edge(il_clk)) then
    --fifo_rows(1)(to_integer(su_addr_wr)) <= svn_mask(19);
    --svn_mask(14) <= fifo_rows(1)(to_integer(su_addr_rd));
    fifo_row1(to_integer(su_addr_wr)) <= svn_mask(19);
    svn_mask(14) <= fifo_row1(to_integer(su_addr_rd));
  end if;
end process;

ovn_mask(14)       <= svn_mask(14);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(13) <= svn_mask(14);
   -- end if;
  end if;
end process;

ovn_mask(13)       <= svn_mask(13);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(12) <= svn_mask(13);
   -- end if;
  end if;
end process;

ovn_mask(12)       <= svn_mask(12);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(11) <= svn_mask(12);
   -- end if;
  end if;
end process;

ovn_mask(11)       <= svn_mask(11);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(10) <= svn_mask(11);
  --  end if;
  end if;
end process;

ovn_mask(10)       <= svn_mask(10);

------------------------------------------------------------------------------
-- FORTH ROW
------------------------------------------------------------------------------
process(il_clk)
begin
  if(rising_edge(il_clk)) then
    --fifo_rows(2)(to_integer(su_addr_wr)) <= svn_mask(14);
    --svn_mask(9) <= fifo_rows(2)(to_integer(su_addr_rd));
    fifo_row2(to_integer(su_addr_wr)) <= svn_mask(14);
    svn_mask(9) <= fifo_row2(to_integer(su_addr_rd));
  end if;
end process;

ovn_mask(9)       <= svn_mask(9);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(8) <= svn_mask(9);
  --  end if;
  end if;
end process;

ovn_mask(8)       <= svn_mask(8);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(7) <= svn_mask(8);
  --  end if;
  end if;
end process;

ovn_mask(7)       <= svn_mask(7);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(6) <= svn_mask(7);
  --  end if;
  end if;
end process;

ovn_mask(6)       <= svn_mask(6);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(5) <= svn_mask(6);
  --  end if;
  end if;
end process;

ovn_mask(5)       <= svn_mask(5);


------------------------------------------------------------------------------
-- FIFTH ROW
------------------------------------------------------------------------------
process(il_clk)
begin
  if(rising_edge(il_clk)) then
    --fifo_rows(3)(to_integer(su_addr_wr)) <= svn_mask(9);
    --svn_mask(4) <= fifo_rows(3)(to_integer(su_addr_rd));
    fifo_row3(to_integer(su_addr_wr)) <= svn_mask(9);
    svn_mask(4) <= fifo_row3(to_integer(su_addr_rd));
  end if;
end process;

ovn_mask(4)       <= svn_mask(4);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(3) <= svn_mask(4);
  --  end if;
  end if;
end process;

ovn_mask(3)       <= svn_mask(3);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(2) <= svn_mask(3);
  --  end if;
  end if;
end process;

ovn_mask(2)       <= svn_mask(2);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(1) <= svn_mask(2);
  --  end if;
  end if;
end process;

ovn_mask(1)       <= svn_mask(1);

process(il_clk)
begin
  if (rising_edge(il_clk)) then
  --  if (il_wr='1') then
      svn_mask(0) <= svn_mask(1);
  --  end if;
  end if;
end process;

ovn_mask(0)       <= svn_mask(0);

end Behavioral;