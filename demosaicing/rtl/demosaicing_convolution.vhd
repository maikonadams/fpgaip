
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.comm_types_pkg.all;

entity demosaicing_convolution is
generic( 
  constant GS_INC_DSP_USAGE           : string := "yes"; 
  constant GI_MASK_SIZE               : integer := 5;
  constant GI_PIXEL_WIDTH             : integer := 8; 
  constant GI_IMG_HEIGHT              : integer := 8; 
  constant GI_IMG_WIDTH               : integer := 8 -- 8x8 and 8*2 ... memory is from 0 .. to 16= 17elements
);
Port ( 
-- system signals
  il_clk                              : in  std_logic;
  il_rst                              : in  std_logic;

  il_vld                              : in std_logic; -- coming from the Master input
  iv_bgbgrr_code                      : in std_logic_vector(3 downto 0);
  ivn_mask                            : in std_logic_vector_xN(GI_MASK_SIZE*GI_MASK_SIZE -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0);
  
  ov_r                                : out STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);
  ov_g                                : out STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0);
  ov_b                                : out STD_LOGIC_VECTOR (GI_PIXEL_WIDTH -1 downto 0)  
);
end demosaicing_convolution;

architecture Behavioral of demosaicing_convolution is
 ------------------------------------------------------------------------------
 -- Constants
 ------------------------------------------------------------------------------
 constant CI_DSP_PIX_EXTRA_BITS       : integer := 5; -- max coef is 12 which is 4b then +1
 constant CI_DSP_PIX_WIDTH            : integer := GI_PIXEL_WIDTH + CI_DSP_PIX_EXTRA_BITS;
 constant CI_NUM_OF_COEF              : integer := 13;    
-------------------------------------------------------------------------------
-- the mask is bellow and the coeficients follow the order, quantized by 2 or 1b
---_______________
-- |24|23|22|21|20
---_______________
-- |19|18|17|16|15
---_______________
-- |14|13|12|11|10
---_______________
-- |09|08|07|06|05
---_______________
-- |04|03|02|01|00
---_______________
-- in order to use a generic conv operation I will cut only the corners
-- 00 01 05 03 04 09 15 20 21 19 23 24 or 12 out, 25 - 12 = 13 multiplier
---_______________
-- |XX|XX|12|XX|XX
---_______________
-- |XX|11|10|09|XX
---_______________
-- |08|07|06|05|04
---_______________
-- |XX|03|02|01|XX
---_______________
-- |XX|XX|00|XX|XX
---_______________
---- *2

  constant CI_1b_Quant                  : integer := 2;
  type t_Coef is array (12 downto 0) of integer;

------------ coeficients are quantized already

  constant CI_COEF_GatRnB                : t_Coef := 
                              (-2,
                             0, 4,0, 
			 -2, 4, 8,4,-2,
                              0,4,0,
                               -2); 

  constant CI_COEF_RatGR                 : t_Coef := 
                               (1,
                             -2,0,-2, 
                          -2,8,10,8,-2,
                             -2,0,-2,
                                1);

  constant CI_COEF_RatGB                 : t_Coef := 
                              (-2,
                            -2, 8,-2, 
                         1, 0, 10,0,1,
                            -2, 8,-2,
                               -2);

  constant CI_COEF_RatB                  : t_Coef := 
                              (-3,
                             4, 0,4, 
                        -3, 0, 12,0,-3,
                             4, 0, 4,
                               -3);

  
  constant CI_COEF_BatGB                 : t_Coef := CI_COEF_RatGR;
  constant CI_COEF_BatGR                 : t_Coef := CI_COEF_RatGB;
  constant CI_COEF_BatR                  : t_Coef := CI_COEF_RatB;
  ------------------------------------------------------------------------------
  -- Data Types
  ------------------------------------------------------------------------------
  subtype dsp_pixel_type           is std_logic_vector(CI_DSP_PIX_WIDTH -1 downto 0);
  subtype dsp_pixel_ext_type       is std_logic_vector(CI_DSP_PIX_WIDTH downto 0);

  ------------------------------------------------------------------------------
  -- Signals / Variables
  ------------------------------------------------------------------------------
  signal sv_bgbgrr_codez1               : std_logic_vector(3 downto 0);
  signal sv_bgbgrr_codez2               : std_logic_vector(3 downto 0);
  signal sv_bgbgrr_codez3               : std_logic_vector(3 downto 0);
  
  signal mask                           : std_logic_vector_xN(CI_NUM_OF_COEF -1 downto 0)(GI_PIXEL_WIDTH -1 downto 0);
  signal maskz1                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal maskz2                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal maskz3                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal maskz4                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  signal maskz5                         : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);

  signal testdsp                        : std_logic_vector(GI_PIXEL_WIDTH*2 -1 downto 0);
  
  signal conv0                          : signed_xN(CI_NUM_OF_COEF -1  downto 0)(CI_DSP_PIX_WIDTH  downto 0);
  signal conv1                          : signed_xN(CI_NUM_OF_COEF  downto 0)(CI_DSP_PIX_WIDTH  downto 0);

  signal rgbtemp0                       : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemp1                       : signed(CI_DSP_PIX_WIDTH  downto 0);

  signal rgbtemp00                      : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemp11                      : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps00                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps10                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps01                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps11                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps02                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps12                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps03                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps13                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps04                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps14                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps05                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps15                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  signal rgbtemps06                    : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtemps16                    : signed(CI_DSP_PIX_WIDTH  downto 0);
     
  signal rgbtempss00                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempss10                     : signed(CI_DSP_PIX_WIDTH  downto 0);
     
  signal rgbtempss01                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempss11                     : signed(CI_DSP_PIX_WIDTH  downto 0);
     
  signal rgbtempss02                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempss12                     : signed(CI_DSP_PIX_WIDTH  downto 0);
     
  signal rgbtempss03                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempss13                     : signed(CI_DSP_PIX_WIDTH  downto 0);
     
  signal rgbtempsss00                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempsss10                     : signed(CI_DSP_PIX_WIDTH  downto 0);
          
  signal rgbtempsss01                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  signal rgbtempsss11                     : signed(CI_DSP_PIX_WIDTH  downto 0);
  
  attribute use_dsp48                   : string;
  attribute use_dsp48 of conv0          : signal is GS_INC_DSP_USAGE;
  attribute use_dsp48 of conv1          : signal is GS_INC_DSP_USAGE;
  
begin

  mask(12) <= ivn_mask(22);
  mask(11) <= ivn_mask(18);
  mask(10) <= ivn_mask(17);
  mask(9)  <= ivn_mask(16);
  mask(8)  <= ivn_mask(14);
  mask(7)  <= ivn_mask(13);
  mask(6)  <= ivn_mask(12);
  mask(5)  <= ivn_mask(11);
  mask(4)  <= ivn_mask(10);
  mask(3)  <= ivn_mask(8);
  mask(2)  <= ivn_mask(7);
  mask(1)  <= ivn_mask(6);
  mask(0)  <= ivn_mask(2);

  process(il_clk)
  begin
    if rising_edge(il_clk) then
      maskz1 <= ivn_mask(12);   
      maskz2 <= maskz1;
      maskz3 <= maskz2;
      maskz4 <= maskz3;
      maskz5 <= maskz4;
    end if;
  end process;

  process(il_clk)
  begin
    if rising_edge(il_clk) then
      sv_bgbgrr_codez1 <= iv_bgbgrr_code;
      sv_bgbgrr_codez2 <= sv_bgbgrr_codez1; 
      sv_bgbgrr_codez3 <= sv_bgbgrr_codez2;
    end if;
  end process;
  
  process(il_clk)
  begin
    if rising_edge(il_clk) then
      testdsp <= std_logic_vector(signed(maskz1) * signed(maskz2));   
    end if;
  end process;

  process(il_clk)
  begin
    if rising_edge(il_clk) then
      for i in 12 downto 0 loop
      case iv_bgbgrr_code is 
        when "0001" => --r   generate G and B
          conv0(i) <= signed('0'&mask(i))*to_signed(CI_COEF_GatRnB(i),CI_DSP_PIX_EXTRA_BITS);  -- G at R locations
          conv1(i) <= signed('0'&mask(i))*to_signed(CI_COEF_BatR(i)  ,CI_DSP_PIX_EXTRA_BITS);  -- B at R locations
        when "0010" => --gr  generate R and B
          conv0(i) <= signed('0'&mask(i))*to_signed(CI_COEF_RatGR(i) ,CI_DSP_PIX_EXTRA_BITS);  -- 
          conv1(i) <= signed('0'&mask(i))*to_signed(CI_COEF_BatGR(i) ,CI_DSP_PIX_EXTRA_BITS);  --
        when "0100" => --gb  generate R and B
          conv0(i) <= signed('0'&mask(i))*to_signed(CI_COEF_RatGB(i) ,CI_DSP_PIX_EXTRA_BITS);
          conv1(i) <= signed('0'&mask(i))*to_signed(CI_COEF_BatGB(i) ,CI_DSP_PIX_EXTRA_BITS);
        when "1000" => --b   generate G and R  
          conv0(i) <= signed('0'&mask(i))*to_signed(CI_COEF_GatRnB(i),CI_DSP_PIX_EXTRA_BITS); -- G at B locations
          conv1(i) <= signed('0'&mask(i))*to_signed(CI_COEF_RatB(i)  ,CI_DSP_PIX_EXTRA_BITS); -- R at Blue 
        when others =>
          conv0(i) <= signed('0'&mask(i))*to_signed(CI_COEF_GatRnB(i),CI_DSP_PIX_EXTRA_BITS); 
          conv1(i) <= signed('0'&mask(i))*to_signed(CI_COEF_GatRnB(i),CI_DSP_PIX_EXTRA_BITS);
      end case;
      end loop;  
    end if;
  end process;

--  process(il_clk)
--  begin
--    if rising_edge(il_clk) then 
--      rgbtemp0 <= (conv0(0) + conv0(1)) + (conv0(2) + conv0(3)) + (conv0(4) + conv0(5)) 
--                + (conv0(6) + conv0(7)) + (conv0(8) + conv0(9)) + (conv0(10) + conv0(11)) +conv0(12);
--      
--      rgbtemp1 <= (conv1(0) + conv1(1)) + (conv1(2) + conv1(3)) + (conv1(4) + conv1(5)) 
--                + (conv1(6) + conv1(7)) + (conv1(8) + conv1(9)) + (conv1(10) + conv1(11)) +conv1(12) ;   
--    end if;
--  end process; 

-------------------------------------
----------- CLK 1
--------------------------------------
  process(il_clk)
  begin
    if rising_edge(il_clk) then 
      rgbtemps00 <=            (conv0(0) + conv0(1));  
      rgbtemps01 <=            (conv0(2) + conv0(3)); 
      rgbtemps02 <=            (conv0(4) + conv0(5)); 
      rgbtemps03 <=            (conv0(6) + conv0(7));
      rgbtemps04 <=            (conv0(8) + conv0(9));
      rgbtemps05 <=            (conv0(10) + conv0(11)); 
      rgbtemps06 <=            conv0(12);
      
      rgbtemps10 <=            (conv1(0) + conv1(1));  
      rgbtemps11 <=            (conv1(2) + conv1(3)); 
      rgbtemps12 <=            (conv1(4) + conv1(5)); 
      rgbtemps13 <=            (conv1(6) + conv1(7));
      rgbtemps14 <=            (conv1(8) + conv1(9));
      rgbtemps15 <=            (conv1(10) + conv1(11)); 
      rgbtemps16 <=            conv1(12);  
    end if;
  end process; 

-------------------------------------
----------- CLK 2
--------------------------------------
  process(il_clk)
  begin
    if rising_edge(il_clk) then
       rgbtempss00 <= rgbtemps00 + rgbtemps01; 
       rgbtempss01 <= rgbtemps02 + rgbtemps03;
       rgbtempss02 <= rgbtemps04 + rgbtemps05;
       rgbtempss03 <= rgbtemps06;
       
       rgbtempss10 <= rgbtemps10 + rgbtemps11; 
       rgbtempss11 <= rgbtemps12 + rgbtemps13;
       rgbtempss12 <= rgbtemps14 + rgbtemps15;
       rgbtempss13 <= rgbtemps16 ;
     end if;
   end process; 

-------------------------------------
----------- CLK 3
--------------------------------------
  process(il_clk)
  begin
    if rising_edge(il_clk) then
      rgbtempsss00 <= rgbtempss00 + rgbtempss01; 
      rgbtempsss01 <= rgbtempss02 + rgbtempss03;
          
      rgbtempsss10 <= rgbtempss10 + rgbtempss11; 
      rgbtempsss11 <= rgbtempss12 + rgbtempss13;    
      end if;
  end process; 
  
-------------------------------------
----------- CLK 4
-------------------------------------- 
   
  process(il_clk)
  begin
    if rising_edge(il_clk) then
      rgbtemp0 <= rgbtempsss00 + rgbtempsss01; 
                
      rgbtemp1 <= rgbtempsss10 + rgbtempsss11;
    end if;
  end process; 
  
  

  -- HANDLING UNDERFLOW AND OVERFLOW

  rgbtemp00 <= (others=>'0') when rgbtemp0(CI_DSP_PIX_WIDTH )   = '1' else 
               (others=>'1') when rgbtemp0(CI_DSP_PIX_WIDTH -1) = '1' else  
                 rgbtemp0;

  rgbtemp11 <= (others=>'0') when rgbtemp1(CI_DSP_PIX_WIDTH )   ='1' else
               (others=>'1') when rgbtemp1(CI_DSP_PIX_WIDTH -1 )='1' else 
                 rgbtemp1; 
  
  -- De quantize and assign to the right rgb value
  process(il_clk)
  begin
    if rising_edge(il_clk) then
      case sv_bgbgrr_codez3 is --iv_bgbgrr_code
        when "0001" => --r   generate G and B
          ov_r <= maskz5;  --z2  
          ov_g <= std_logic_vector(rgbtemp00(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));
          ov_b <= std_logic_vector(rgbtemp11(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));
       
        when "0010" => --gr  generate R and B
          ov_r <= std_logic_vector(rgbtemp00(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));
          ov_g <= maskz5;
          ov_b <= std_logic_vector(rgbtemp11(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));
         
        when "0100" => --gb  generate R and B
          ov_r <= std_logic_vector(rgbtemp00(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));
          ov_g <= maskz5;
          ov_b <= std_logic_vector(rgbtemp11(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1));

        when "1000" => --b   generate G and R 
          ov_r <= std_logic_vector(rgbtemp11(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1)); --rgbtemp0
          ov_g <= std_logic_vector(rgbtemp00(CI_DSP_PIX_WIDTH -2 downto CI_DSP_PIX_WIDTH -  GI_PIXEL_WIDTH -1)); --rgbtemp1 
          ov_b <= maskz5;

        when others =>
          ov_r <= (others=>'0');
          ov_g <= (others=>'0');
          ov_b <= (others=>'0'); 
      end case;
    end if;
  end process; 

end Behavioral;
