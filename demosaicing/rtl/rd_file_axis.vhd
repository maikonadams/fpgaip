
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

entity rd_file_axis is

generic ( 
  gs_filename             : string;
  GI_PIXEL_WIDTH          : integer := 8  ); -- input filename

port (
  il_clk                  : in  std_logic;
  il_rst                  : in  std_logic;
  ol_eof                  : out std_logic;
  
  il_frame_start          : in  std_logic;
  
  -- output from file
  ov_m_axis_tdata         : out std_logic_vector(GI_PIXEL_WIDTH -1 downto 0);
  ol_m_axis_tvalid        : out std_logic;
  il_m_axis_tready        : in  std_logic;
  ol_m_axis_tlast         : out std_logic);

end entity;


architecture behaviour of rd_file_axis is

  signal  sl_frame_active   : std_logic := '0';

begin

  process(il_clk)
  begin
    if (rising_edge(il_clk)) then
      if (il_rst = '0') then
        sl_frame_active <= '0';
      elsif (il_frame_start = '1') then
        sl_frame_active <= '1';
      end if;
    end if;
  end process;

------------------------------
-- Read input file --
------------------------------
  process(il_clk)
    file f_inputfile         : text open read_mode is gs_filename;
    variable vl_inputline    : line;
    
    variable vv_tvalid_hex   : std_logic_vector(3 downto 0);
    variable vv_tlast_hex    : std_logic_vector(3 downto 0);
    variable vv_pixel_hex    : std_logic_vector(7 downto 0);
  begin
    if (rising_edge(il_clk)) then
      if (il_rst = '0') then
        ol_m_axis_tvalid <= '0';
        ol_m_axis_tlast  <= '0';
        ov_m_axis_tdata  <= (others => '0');
        ol_eof           <= '0';
      elsif (il_m_axis_tready = '1' and sl_frame_active = '1') then
        if (not endfile(f_inputfile)) then
          readline(f_inputfile, vl_inputline);

          hread(vl_inputline, vv_tvalid_hex);
          hread(vl_inputline, vv_tlast_hex);
          hread(vl_inputline, vv_pixel_hex);
          
          ol_m_axis_tvalid <= vv_tvalid_hex(0);
          ol_m_axis_tlast  <= vv_tlast_hex(0);
          ov_m_axis_tdata  <= vv_pixel_hex; 
          ol_eof           <= '0';
        else
          ol_m_axis_tvalid <= '0';
          ol_m_axis_tlast  <= '0';
          ov_m_axis_tdata  <= (others=>'0'); 
          ol_eof           <= '0';
        end if;
      end if;
    end if;
  end process; 

end behaviour;