library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;

entity spn_filter_axis_fifo is
generic( 
  constant G_PIXEL_DEPTH   : integer := 16; 
  constant G_FIFO_SIZE     : integer := 8 -- 8x8 and 8*2 ... memory is from 0 .. to 16= 17elements
);
Port ( 
-- system signals
  il_clk                   : in  std_logic;
  il_rst                   : in  std_logic;

  iv_yin                   : in   STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);

  ov_yij                   : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
  ov_yi_1jp1               : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
  ov_yi_1j                 : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
  ov_yi_1j_1               : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
  ov_yi_2j                 : out  STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0));
end spn_filter_axis_fifo;

architecture Behavioral of spn_filter_axis_fifo is

type FIFO_wRAM is array(0 to (G_FIFO_SIZE -1) ) of std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
signal fifo_inst_i_1_jp1                 : FIFO_wRAM;
signal fifo_inst_i_2j                    : FIFO_wRAM;

attribute ram_style                      : string;
attribute ram_style of fifo_inst_i_1_jp1 : signal is "block";
attribute ram_style of fifo_inst_i_2j    : signal is "block";

constant ADDR_LIM                        : integer := (G_FIFO_SIZE -1);
constant C_ADDR_NUM_BITS                 : integer := integer(ceil(log2(real(G_FIFO_SIZE -1))));

signal su_addr_w                         : unsigned(C_ADDR_NUM_BITS -1 downto 0);
signal su_addr_r                         : unsigned(C_ADDR_NUM_BITS -1 downto 0);

signal sv_yij                            : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_1jp1                        : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_yi_2j                          : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);

signal sv_temp_i_1j                      : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);
signal sv_temp_i_1j_1                    : STD_LOGIC_VECTOR (G_PIXEL_DEPTH -1 downto 0);

begin

update_address: process(il_clk)
begin
  if (rising_edge(il_clk)) then
    if (su_addr_w < (ADDR_LIM -1)) then
      su_addr_w <= su_addr_w +1;
      if (su_addr_w = (ADDR_LIM -1)) then
        su_addr_r  <= (others => '0');
      else
        su_addr_r  <= su_addr_r + 1; 
      end if;
    else
      su_addr_w <= (others => '0');
      su_addr_r(su_addr_r'length-1 downto 1) <= (others => '0');
      su_addr_r(0) <= '1';
    end if;
  end if;
end process update_address;

-- first assigning
yij_U:process(il_clk)
begin
  if (rising_edge(il_clk)) then
    sv_yij <= iv_yin;
  end if;
end process yij_U;
ov_yij     <= sv_yij;

-- FIFO i_1_jp1
i_1_jp1: PROCESS(il_clk)
BEGIN
  if(rising_edge(il_clk)) then
    fifo_inst_i_1_jp1(to_integer(su_addr_w)) <= sv_yij;
    sv_yi_1jp1 <= fifo_inst_i_1_jp1(to_integer(su_addr_r));
  end if;
END PROCESS i_1_jp1;
ov_yi_1jp1 <= sv_yi_1jp1;

-- FIFO i_1j
i_1j: process(il_clk)
begin
  if (rising_edge(il_clk)) then
    sv_temp_i_1j <= sv_yi_1jp1;
  end if;
end process i_1j;
ov_yi_1j <= sv_temp_i_1j;

-- FIFO i_1j_1 temp_i_1j_1
i_1j_1: process(il_clk)
begin
  if (rising_edge(il_clk)) then
    sv_temp_i_1j_1 <= sv_temp_i_1j;
  end if;
end process i_1j_1;
ov_yi_1j_1 <= sv_temp_i_1j_1;

-- FIFO i_2j
i_2j: PROCESS(il_clk)
BEGIN
  if(rising_edge(il_clk)) then  
    fifo_inst_i_2j(to_integer(su_addr_w)) <= sv_temp_i_1j_1;
    sv_yi_2j <= fifo_inst_i_2j(to_integer(su_addr_r));
  end if;
END PROCESS i_2j;
ov_yi_2j <= sv_yi_2j;


end Behavioral;