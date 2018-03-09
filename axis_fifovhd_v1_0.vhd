library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity axis_fifovhd_v1_0 is
	generic (
		-- Users to add parameters here
        ADDR_WIDTH : integer := 12;
        C_AXIS_TDATA_WIDTH : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line
        

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end axis_fifovhd_v1_0;

architecture arch_imp of axis_fifovhd_v1_0 is

	-- component declaration
	component axis_fifovhd_v1_0_S00_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component axis_fifovhd_v1_0_S00_AXIS;

	component axis_fifovhd_v1_0_M00_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component axis_fifovhd_v1_0_M00_AXIS;
	
	
	signal wr_ptr_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
	signal wr_ptr_next : std_logic_vector(ADDR_WIDTH downto 0);
	signal wr_ptr_gray_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
	signal wr_ptr_gray_next : std_logic_vector(ADDR_WIDTH downto 0);
	signal wr_addr_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
	
	signal rd_ptr_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    signal rd_ptr_next : std_logic_vector(ADDR_WIDTH downto 0);
    signal rd_ptr_gray_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    signal rd_ptr_gray_next : std_logic_vector(ADDR_WIDTH downto 0);
    signal rd_addr_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    
    signal wr_ptr_gray_sync1_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    signal wr_ptr_gray_sync2_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    signal rd_ptr_gray_sync1_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    signal rd_ptr_gray_sync2_reg : std_logic_vector(ADDR_WIDTH downto 0) := (others=>'0');
    
    signal s00_rst_sync1_reg : std_logic := '1';
    signal s00_rst_sync2_reg : std_logic := '1';
    signal s00_rst_sync3_reg : std_logic := '1';
    signal m00_rst_sync1_reg : std_logic := '1';
    signal m00_rst_sync2_reg : std_logic := '1';
    signal m00_rst_sync3_reg : std_logic := '1';
    
    type t_Memory is array (2**ADDR_WIDTH -1 downto 0) of std_logic_vector(C_AXIS_TDATA_WIDTH + 2 - 1 downto 0);
    --signal r_Mem : t_Memory;
    signal mem : t_Memory;
    signal mem_read_data_reg : std_logic_vector(C_AXIS_TDATA_WIDTH+2-1 downto 0) := (others=>'0');
    signal mem_read_data_reg_temp : std_logic_vector(C_AXIS_TDATA_WIDTH+2-1 downto 0) := (others=>'0');
    signal mem_read_data_valid_reg : std_logic :='0';
    signal mem_read_data_valid_next : std_logic;
    signal mem_write_data : std_logic_vector(C_AXIS_TDATA_WIDTH+2-1 downto 0);
    signal mem_write_data_temp : std_logic_vector(C_AXIS_TDATA_WIDTH+2-1 downto 0);
    signal m00_data_reg : std_logic_vector(C_AXIS_TDATA_WIDTH+2-1 downto 0) := (others=>'0');
    signal m00_axis_tvalid_reg : std_logic :='0';
    signal m00_axis_tvalid_next : std_logic;
    signal full : std_logic;
    signal empty : std_logic;
    signal write : std_logic;
    signal read : std_logic;
    signal store_output : std_logic;
    
    signal s00_axis_tdatax2 : std_logic_vector(C_S00_AXIS_TDATA_WIDTH -1 downto 0);

begin

    full <= '1' when ( (wr_ptr_gray_reg(ADDR_WIDTH) /= rd_ptr_gray_sync2_reg(ADDR_WIDTH)) and 
                       (wr_ptr_gray_reg(ADDR_WIDTH-1) /= rd_ptr_gray_sync2_reg(ADDR_WIDTH-1)) and
                       (wr_ptr_gray_reg(ADDR_WIDTH-2 downto 0) = rd_ptr_gray_sync2_reg(ADDR_WIDTH-2 downto 0))) else '0';
                      
    empty <= '1' when (rd_ptr_gray_reg = wr_ptr_gray_sync2_reg) else '0';
    
    s00_axis_tready <= (not(full) and not(s00_rst_sync3_reg));
    m00_axis_tvalid <= m00_axis_tvalid_reg; 
    
    s00_axis_tdatax2 <= s00_axis_tdata(C_AXIS_TDATA_WIDTH -2 downto 0)&'0';
    
    mem_write_data_temp <=  s00_axis_tlast & '0' & s00_axis_tdatax2;
    --mem_write_data <= '0'&mem_write_data_temp(C_AXIS_TDATA_WIDTH +2-1 downto 1); 
    mem_write_data <= mem_write_data_temp;
    
    m00_axis_tlast <= m00_data_reg(C_AXIS_TDATA_WIDTH+2-1);
    m00_axis_tdata <= m00_data_reg(C_AXIS_TDATA_WIDTH-1 downto 0);
    
    --reset synchronization
    process(s00_axis_aclk)
    begin
    if rising_edge(s00_axis_aclk) then
        if (not(s00_axis_aresetn)='1') then
            s00_rst_sync1_reg <= '1';  
            s00_rst_sync2_reg <= '1'; 
            s00_rst_sync3_reg <= '1';         
        else
            s00_rst_sync1_reg <= '0'; 
            s00_rst_sync2_reg <= s00_rst_sync1_reg or m00_rst_sync1_reg; 
            s00_rst_sync3_reg <= s00_rst_sync2_reg; 
        end if;
    end if;
    end process;
    
    process(m00_axis_aclk)
        begin
        if rising_edge(m00_axis_aclk) then
            if (not(m00_axis_aresetn)='1') then
                m00_rst_sync1_reg <= '1';  
                m00_rst_sync2_reg <= '1'; 
                m00_rst_sync3_reg <= '1';         
            else
                m00_rst_sync1_reg <= '0'; 
                m00_rst_sync2_reg <= s00_rst_sync1_reg or m00_rst_sync1_reg; 
                m00_rst_sync3_reg <= m00_rst_sync2_reg; 
            end if;
        end if;
        end process;
        
    -- write logic
    writeblock : process(s00_axis_tvalid,full,write, wr_ptr_next, wr_ptr_gray_next)
    begin
        write <= '0';
        wr_ptr_next <= wr_ptr_reg;  
        wr_ptr_gray_next <= wr_ptr_gray_reg; 
        if (s00_axis_tvalid='1') then
            if (not(full)='1') then
                 write <= '1'; 
                 wr_ptr_next <= wr_ptr_reg + 1; 
                 wr_ptr_gray_next <= wr_ptr_next xor ('0'&wr_ptr_next(ADDR_WIDTH downto 1)); 
            end if;
        end if;
    end process writeblock;
    
    process(s00_axis_aclk) 
    begin
        if rising_edge(s00_axis_aclk) then
            if (s00_rst_sync3_reg='1') then
                wr_ptr_reg <= (others=>'0');  
                wr_ptr_gray_reg <= (others=>'0'); 
            else
                wr_ptr_reg <= wr_ptr_next; 
                wr_ptr_gray_reg <= wr_ptr_gray_next; 
            end if;
            wr_addr_reg <= wr_ptr_next;
            if (write='1')then
               mem(to_integer(unsigned(wr_addr_reg))) <= mem_write_data; 
                --mem(to_integer(unsigned(wr_addr_reg))) <=  (1 + (mem_write_data))  ;
            end if;
        end if;
    end process;
    
    -- pointer synchronization
    process( s00_axis_aclk) 
    begin 
    if rising_edge(s00_axis_aclk) then
        if (s00_rst_sync3_reg='1') then 
            rd_ptr_gray_sync1_reg <= (others=>'0');  
            rd_ptr_gray_sync2_reg <= (others=>'0'); 
         else 
            rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg; 
            rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg; 
        end if;
       end if;
    end process;
    
    process( m00_axis_aclk) 
    begin 
       if rising_edge(m00_axis_aclk) then
           if (m00_rst_sync3_reg='1') then 
               wr_ptr_gray_sync1_reg <= (others=>'0');  
               wr_ptr_gray_sync2_reg <= (others=>'0'); 
            else 
               wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg; 
               wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg; 
           end if;
      end if;
    end process;
    
    -- read logic
    readblock: process(read,empty,rd_ptr_next,rd_ptr_gray_next,rd_ptr_reg,store_output,mem_read_data_valid_reg)
    begin
        read <='0';
        rd_ptr_next <= rd_ptr_reg;  
        rd_ptr_gray_next <= rd_ptr_gray_reg;  
        mem_read_data_valid_next <= mem_read_data_valid_reg;
        if ((store_output or not(mem_read_data_valid_reg))='1') then
            if(not(empty)='1') then
                read <='1';
                mem_read_data_valid_next <= '1';
                rd_ptr_next <= rd_ptr_reg + 1;
                rd_ptr_gray_next <= (rd_ptr_next xor ('0'&rd_ptr_next(ADDR_WIDTH downto 1)));
            else
                mem_read_data_valid_next <= '0';
            end if;
        end if;
    end process readblock;
    
    process(m00_axis_aclk)
    begin
        if rising_edge(m00_axis_aclk) then
            if (m00_rst_sync3_reg='1') then
                rd_ptr_reg <= (others=>'0');  
                 rd_ptr_gray_reg <= (others=>'0'); 
                 mem_read_data_valid_reg <= '0';  
            else
                rd_ptr_reg <= rd_ptr_next;  
                rd_ptr_gray_reg <= rd_ptr_gray_next;  
                mem_read_data_valid_reg <= mem_read_data_valid_next;
            end if;  
            
            rd_addr_reg <= rd_ptr_next;  
              
            if (read='1') then  
                  mem_read_data_reg <= mem(to_integer(unsigned(rd_addr_reg))); --modified here just to try 
                  --mem_read_data_reg <= mem_read_data_reg_temp +1;
            end if;       
        end if;    
    end process;
    
    
    -- output register
    process(m00_axis_tvalid_reg, m00_axis_tready, mem_read_data_valid_reg)
    begin
        store_output <= '0';
        m00_axis_tvalid_next <= m00_axis_tvalid_reg;
        if ((m00_axis_tready or not(m00_axis_tvalid_reg))='1') then
            store_output <= '1';
            m00_axis_tvalid_next <= mem_read_data_valid_reg;
        end if;
    end process;
    
    process(m00_axis_aclk) 
    begin
        if rising_edge(m00_axis_aclk) then
           if (m00_rst_sync3_reg='1') then
                m00_axis_tvalid_reg <= '0';
           else
                m00_axis_tvalid_reg <= m00_axis_tvalid_next;
           end if;
           
           if(store_output ='1') then
                m00_data_reg <= mem_read_data_reg;
           end if;           
        end if;
    end process;
    
-- Instantiation of Axi Bus Interface S00_AXIS
--axis_fifovhd_v1_0_S00_AXIS_inst : axis_fifovhd_v1_0_S00_AXIS
--	generic map (
--		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
--	)
--	port map (
--		S_AXIS_ACLK	=> s00_axis_aclk,
--		S_AXIS_ARESETN	=> s00_axis_aresetn,
--		S_AXIS_TREADY	=> s00_axis_tready,
--		S_AXIS_TDATA	=> s00_axis_tdata,
--		S_AXIS_TSTRB	=> s00_axis_tstrb,
--		S_AXIS_TLAST	=> s00_axis_tlast,
--		S_AXIS_TVALID	=> s00_axis_tvalid
--	);

---- Instantiation of Axi Bus Interface M00_AXIS
--axis_fifovhd_v1_0_M00_AXIS_inst : axis_fifovhd_v1_0_M00_AXIS
--	generic map (
--		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
--		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
--	)
--	port map (
--		M_AXIS_ACLK	=> m00_axis_aclk,
--		M_AXIS_ARESETN	=> m00_axis_aresetn,
--		M_AXIS_TVALID	=> m00_axis_tvalid,
--		M_AXIS_TDATA	=> m00_axis_tdata,
--		M_AXIS_TSTRB	=> m00_axis_tstrb,
--		M_AXIS_TLAST	=> m00_axis_tlast,
--		M_AXIS_TREADY	=> m00_axis_tready
--	);

	-- Add user logic here
	
	

	-- User logic ends

end arch_imp;
