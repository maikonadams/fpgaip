--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:01:05 03/04/2018
-- Design Name:   
-- Module Name:   /home/maikon/Dropbox/verilog/ExamplesVerilog/conv_fifo_3x3_tb.vhd
-- Project Name:  ExamplesVerilog
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: conv_fifo_3x3
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY conv_fifo_3x3_tb IS
END conv_fifo_3x3_tb;
 
ARCHITECTURE behavior OF conv_fifo_3x3_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT conv_fifo_3x3
    PORT(
         pixel_stream : IN  std_logic_vector(2 downto 0);
         clock : IN  std_logic;
         conv_pixel : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal pixel_stream : std_logic_vector(2 downto 0) := (others => '0');
   signal clock : std_logic := '0';

 	--Outputs
   signal conv_pixel : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: conv_fifo_3x3 PORT MAP (
          pixel_stream => pixel_stream,
          clock => clock,
          conv_pixel => conv_pixel
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here
	   pixel_stream <= "101";
		wait for clock_period*1;
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "001";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "101";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "110";
		wait for clock_period*1;
		
		pixel_stream <= "100";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "101";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "001";
		wait for clock_period*1;
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "100";
		wait for clock_period*1;
		
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "001";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "001";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "100";
		wait for clock_period*1;
		pixel_stream <= "101";
		wait for clock_period*1;
		pixel_stream <= "100";
		wait for clock_period*1;
		
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "100";
		wait for clock_period*1;
		pixel_stream <= "111";
		wait for clock_period*1;
		
		
		pixel_stream <= "111";
		wait for clock_period*1;
		pixel_stream <= "100";
		wait for clock_period*1;
		pixel_stream <= "000";
		wait for clock_period*1;
		pixel_stream <= "001";
		wait for clock_period*1;
		pixel_stream <= "011";
		wait for clock_period*1;
		pixel_stream <= "010";
		wait for clock_period*1;
		pixel_stream <= "101";
		wait for clock_period*1;
		pixel_stream <= "110";
		wait for clock_period*1;
		

      wait;
   end process;

END;
