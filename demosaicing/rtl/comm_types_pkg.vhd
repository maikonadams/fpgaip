library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package comm_types_pkg is

------------------------------------------------------------------------------
-- General Constants
------------------------------------------------------------------------------

constant CI_RAW_PIXEL_WIDTH                 :integer := 4; --16

-------------------------------------------------------------------------------------------------
-- types
-------------------------------------------------------------------------------------------------

--subtype FIFO_wRAM is array(0 to (GI_IMG_WIDTH -1) ) of std_logic_vector(GI_PIXEL_DEPTH -1 downto 0);
--type MEM_ROWS  is array(0 to (GI_MASK_SIZE -1)) of FIFO_wRAM;
subtype BAYER_PATTERN_TYPE                  is std_logic_vector(3 downto 0);   
 
type std_logic_vector_xN                    is array (natural range <>) of std_logic_vector;
type std_logic_vector_xNxN                  is array (natural range <>) of std_logic_vector_xN;
type std_logic_vector_xNxNxN                is array (natural range <>) of std_logic_vector_xNxN;

type signed_xN                              is array (natural range <>) of signed;
type signed_xNxN                            is array (natural range <>) of signed_xN;

-------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------

end package comm_types_pkg;

package body comm_types_pkg is




end package body comm_types_pkg;