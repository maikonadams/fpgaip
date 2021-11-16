LIBRARY ieee, modelsim_lib;
USE ieee.std_logic_1164.ALL;
use modelsim_lib.util.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use IEEE.math_real."log2";
use IEEE.math_real."round"; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use ieee.std_logic_textio.all;

ENTITY spn_filter_axis_tb IS
generic(
  constant input_axis_image_vectors       : string  := 
       "/home/maikon/Dropbox/PhDSafe/ong_prj/rtlsimlib/isp/spn_filter_axis/input_data/input_axis_image_vectors.txt";
  constant output_axis_image_vectors      : string  := 
       "/home/maikon/Dropbox/PhDSafe/ong_prj/rtlsimlib/isp/spn_filter_axis/output_data/output_axis_image_vectors.txt";
  constant G_PIXEL_DEPTH                  : integer := 4; 
  constant G_IMG_WIDTH                    : integer := 5;
  constant G_IMG_HEIGHT                   : integer := 5 
);
END spn_filter_axis_tb;
 
ARCHITECTURE behavior OF spn_filter_axis_tb IS 

signal sl_clk                             : std_logic;
signal sl_reset                           : std_logic;

signal sv_s_axis_tdata                    : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
signal sl_s_axis_tlast                    : std_logic;
signal sl_s_axis_tvalid                   : std_logic;
signal sl_s_axis_tready                   : std_logic;

signal sv_m_axis_tdata                    : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
signal sl_m_axis_tlast                    : std_logic;
signal sl_m_axis_tvalid                   : std_logic;
signal sl_m_axis_tready                   : std_logic;

-- Clock period definitions
  constant clock_period : time            := 10 ns;

begin

-- Clock process definitions
clock_process :process
begin
  sl_clk <= '0';
  wait for clock_period/2;
  sl_clk <= '1';
  wait for clock_period/2;
end process;


spn_filter_axis_inst : entity work.spn_filter_axis
  generic map
  (
    G_PIXEL_DEPTH                   => G_PIXEL_DEPTH,
    G_IMG_WIDTH                     => G_IMG_WIDTH,
    G_IMG_HEIGHT                    => G_IMG_HEIGHT
  )
  port map
  (
    il_clk                          => sl_clk,
    il_rst                          => sl_reset,

    iv_s_axis_tdata                 => sv_s_axis_tdata,
    il_s_axis_tlast                 => sl_s_axis_tlast,
    il_s_axis_tvalid                => sl_s_axis_tvalid,
    ol_s_axis_tready                => sl_s_axis_tready,

    -- Pixels out as Mono 16
    ov_m_axis_tdata                 => sv_m_axis_tdata,
    ol_m_axis_tlast                 => sl_m_axis_tlast,
    ol_m_axis_tvalid                => sl_m_axis_tvalid,
    il_m_axis_tready                => sl_m_axis_tready
  );


-- Stimulus process
  stim_proc: process
    file in_file                          : TEXT open read_mode is input_axis_image_vectors; 
    file out_file                         : TEXT open write_mode is output_axis_image_vectors;
    variable out_line                     : LINE;
    variable in_line                      : LINE;

    variable vv_s_axis_tdata              : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);
    variable vl_s_axis_tlast              : std_logic;
    variable vl_s_axis_tvalid             : std_logic;
    variable vl_m_axis_tready             : std_logic;

    variable vv_m_axis_tdata              : std_logic_vector(G_PIXEL_DEPTH -1 downto 0);	

   begin		
   -- hold reset state for 100 ns.
     wait for 20 ns;	
     -- wait for clock_period*10;
     -- insert stimulus here 
     sl_reset <= '0';
     wait for 20 ns;
     sl_reset <= '1';
     while not endfile(in_file) loop
       READLINE(in_file, in_line);
       read(in_line, vl_s_axis_tvalid);
       sl_s_axis_tvalid <= vl_s_axis_tvalid;
       read(in_line, vl_m_axis_tready);
       sl_m_axis_tready <= vl_m_axis_tready;
       read(in_line, vl_s_axis_tlast);
       sl_s_axis_tlast <= vl_s_axis_tlast;
       read(in_line, vv_s_axis_tdata);
       sv_s_axis_tdata <= vv_s_axis_tdata;
       wait for clock_period*1;
       write(out_line, vv_m_axis_tdata);
       write(out_line, string'(" "));
       WRITELINE(out_file, out_line);
     end loop;

   wait;
   end process;

END;