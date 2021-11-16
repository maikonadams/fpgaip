library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spn_filter_axis_maxMin is
generic(
  G_PIXEL_DEPTH   : integer := 16
);
Port(
  il_clk          :  in  std_logic;
  iv_pix1         :  in  STD_LOGIC_VECTOR ((G_PIXEL_DEPTH-1) downto 0);
  iv_pix2         :  in  STD_LOGIC_VECTOR ((G_PIXEL_DEPTH-1) downto 0);
  ov_max          :  out std_logic_vector ((G_PIXEL_DEPTH-1) downto 0);
  ov_min          :  out std_logic_vector ((G_PIXEL_DEPTH-1) downto 0)
);
end spn_filter_axis_maxMin;

architecture Behavioral of  spn_filter_axis_maxMin is
begin

process(il_clk)
begin 
  if rising_edge(il_clk) then
    if (iv_pix1 >  iv_pix2)  then
      ov_max    <= iv_pix1;
      ov_min    <= iv_pix2;
    else
      ov_max    <= iv_pix2;
      ov_min    <= iv_pix1;
    end if;
  end if;
end process;

end Behavioral;