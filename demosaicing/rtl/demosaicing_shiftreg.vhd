library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.comm_types_pkg.all;

entity demosaicing_shiftreg is
generic( 
  constant GI_MASK_SIZE          : integer := 3;
  constant GI_PIXEL_DEPTH        : integer := 16
);
Port ( 
-- system signals
  il_clk                         : in  std_logic;
  il_wr                          : in  std_logic; -- coming from the Master input
  iv_pixel                       : in  STD_LOGIC_VECTOR (GI_PIXEL_DEPTH -1 downto 0);

  ovn_mask                       : out std_logic_vector_xN(GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0)
);
end demosaicing_shiftreg;

architecture Behavioral of demosaicing_shiftreg is

signal svn_mask                  : std_logic_vector_xN(GI_MASK_SIZE -1 downto 0)(GI_PIXEL_DEPTH -1 downto 0);

begin

process(il_clk)
begin
  if (rising_edge(il_clk)) then
   -- if (il_wr='1') then
      svn_mask(GI_MASK_SIZE -1) <= iv_pixel;
      for i in GI_MASK_SIZE -2 downto 0 loop  
        svn_mask(i) <= svn_mask(i +1); 
      end loop;
   -- end if;
  end if;
end process;

output_assign: for i in (GI_MASK_SIZE -1) downto 0 generate
  ovn_mask(i) <= svn_mask(i); 
end generate output_assign;

end Behavioral;