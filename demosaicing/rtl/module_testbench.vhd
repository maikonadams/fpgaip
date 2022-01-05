
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.sim_file_pkg.all;

entity module_testbench is

generic
(
  gs_IMAGE_output_file_name           : string;
  gs_IMAGE_output_expected            : string;

  GI_PIXEL_WIDTH                      : integer := 8;
  GI_IMG_WIDTH                        : integer := 768;
  GI_IMG_HEIGHT                       : integer := 512; 
  gi_nr_frames                       : integer := 1  
);
port
(
-- Raw clock signal
  il_clk                             : in    std_logic;
  il_rst                             : in    std_logic;

  --il_error                           : in    std_logic := '0';
  
  iv_s_axis_tdata                    : in  std_logic_vector(3*GI_PIXEL_WIDTH -1 downto 0);
  il_s_axis_tlast                    : in  std_logic;
  il_s_axis_tvalid                   : in  std_logic;
  --ol_s_axis_tready                   : out std_logic;  

  --ol_end_simulation                  : out   std_logic;
  ol_error                           : out   std_logic
  --ol_error_hold                      : out   std_logic
);
end module_testbench;

architecture sim of module_testbench is

signal sv_pixel_r            : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
signal sv_pixel_g            : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
signal sv_pixel_b            : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);

signal sv_pixel_r_ref        : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
signal sv_pixel_g_ref        : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
signal sv_pixel_b_ref        : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);

signal su_cont_pix           : unsigned(32 -1 downto 0);
signal su_cont_error         : unsigned(32 -1 downto 0);

begin

process(il_clk)
begin
  if (rising_edge(il_clk)) then
    sv_pixel_r   <= iv_s_axis_tdata(GI_PIXEL_WIDTH -1 downto 0);
    sv_pixel_g   <= iv_s_axis_tdata(2*GI_PIXEL_WIDTH -1 downto GI_PIXEL_WIDTH);
    sv_pixel_b   <= iv_s_axis_tdata(3*GI_PIXEL_WIDTH -1 downto 2*GI_PIXEL_WIDTH);
  end if;
end process;


------------------------------
-- Read expected output file --
------------------------------
process(il_clk)
    file f_inputfile         : text open read_mode is gs_IMAGE_output_expected;
    variable vl_inputline    : line;

    file f_outputfile        : text open write_mode is gs_IMAGE_output_file_name;
    variable vl_outputline   : line;

    variable vv_pixel_hex_r  : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
    variable vv_pixel_hex_g  : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
    variable vv_pixel_hex_b  : std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  begin
    if (rising_edge(il_clk)) then
      if (il_rst = '0') then
        ol_error      <= '0';
        su_cont_error <= (others => '0');
        su_cont_pix   <= (others => '0');
        
      elsif (il_s_axis_tvalid = '1') then
        if (su_cont_pix = 0) then
          write(vl_outputline, string'(" Writing Debuging Info "));
          writeline(f_outputfile, vl_outputline);
        end if;

        if (not endfile(f_inputfile)) then
          readline(f_inputfile, vl_inputline);
          
          hread(vl_inputline, vv_pixel_hex_r);
          hread(vl_inputline, vv_pixel_hex_g);
          hread(vl_inputline, vv_pixel_hex_b);

	  sv_pixel_r_ref  <= vv_pixel_hex_r;
	  sv_pixel_g_ref  <= vv_pixel_hex_g;
          sv_pixel_b_ref  <= vv_pixel_hex_b;

          su_cont_pix     <= su_cont_pix +1;

          if ( (unsigned(vv_pixel_hex_r) = unsigned(iv_s_axis_tdata(GI_PIXEL_WIDTH -1 downto 0))) AND 
               (unsigned(vv_pixel_hex_g) = unsigned(iv_s_axis_tdata(2*GI_PIXEL_WIDTH -1 downto GI_PIXEL_WIDTH))) AND
               (unsigned(vv_pixel_hex_b) = unsigned(iv_s_axis_tdata(3*GI_PIXEL_WIDTH -1 downto 2*GI_PIXEL_WIDTH)))  ) then
            ol_error <= '0';
          else
            ol_error      <= '1';
            su_cont_error <= su_cont_error +1;
          end if;
          if (su_cont_error =  0 and su_cont_pix  = to_unsigned(GI_IMG_HEIGHT*GI_IMG_WIDTH -1, 32) )  then
            write(vl_outputline, string'(" NO ERRORS !!! : ALL MATCHES "));
          end if;
        end if;
      end if;
    end if;
end process;



end sim;
