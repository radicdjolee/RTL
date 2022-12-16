library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imdct_v15_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
        en_bram_a       : out std_logic; 
        addr_bram_a     : out std_logic_vector(31 downto 0); 
        din_bram_a      : out std_logic_vector(31 downto 0);
        dout_bram_a     : in std_logic_vector(31 downto 0);
        we_bram_a       : out std_logic;
        en_bram_b       : out std_logic; 
        addr_bram_b     : out std_logic_vector(31 downto 0); 
        din_bram_b      : out std_logic_vector(31 downto 0);
        dout_bram_b     : in std_logic_vector(31 downto 0);
        we_bram_b       : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end imdct_v15_0;

architecture arch_imp of imdct_v15_0 is

	-- component declaration
	    component imdct
  	    port(  clk   : in  std_logic;		-- clock input signal
        	   reset : in  std_logic;		-- reset signal (1 = reset)
        	   start : in  std_logic;		-- start=1 means that this block is activated
        	   ready : out std_logic;		-- generate a done signal for one clock pulse when finished
        	   din_a   : in  std_logic_vector( 32-1 downto 0 );	-- signals from memory
        	   dout_a  : out std_logic_vector( 32-1 downto 0 );
			   addr_a  : out std_logic_vector( 32-1 downto 0 );
			   we_a    : out std_logic;
			   en_a    : out std_logic;
			   din_b   : in  std_logic_vector( 32-1 downto 0 );	-- signals from memory
        	   dout_b  : out std_logic_vector( 32-1 downto 0 );
			   addr_b  : out std_logic_vector( 32-1 downto 0 );
			   we_b    : out std_logic;
			   en_b    : out std_logic;
			   block_type_00 : in std_logic_vector( 1 downto 0 );
			   block_type_01 : in std_logic_vector( 1 downto 0 );
			   block_type_10 : in std_logic_vector( 1 downto 0 );
			   block_type_11 : in std_logic_vector( 1 downto 0 );
			   gr    : in std_logic;
			   ch    : in std_logic
    	);
	end component;
	
	component imdct_v15_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		start_axi_o : out  std_logic;	
        block_type_00_axi_o : out std_logic_vector( 1 downto 0 );
        block_type_01_axi_o : out std_logic_vector( 1 downto 0 );
        block_type_10_axi_o : out std_logic_vector( 1 downto 0 );
        block_type_11_axi_o : out std_logic_vector( 1 downto 0 );
        gr_axi_o    : out std_logic;
        ch_axi_o    : out std_logic;
        ready_axi_i : in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component imdct_v15_0_S00_AXI;

        signal start_axi_s : std_logic;	
        signal block_type_00_axi_s : std_logic_vector( 1 downto 0 );
        signal block_type_01_axi_s : std_logic_vector( 1 downto 0 );
        signal block_type_10_axi_s : std_logic_vector( 1 downto 0 );
        signal block_type_11_axi_s : std_logic_vector( 1 downto 0 );
        signal gr_axi_s    : std_logic;
        signal ch_axi_s    : std_logic;
        signal ready_axi_s : std_logic;
        
begin

-- Instantiation of Axi Bus Interface S00_AXI
imdct_v15_0_S00_AXI_inst : imdct_v15_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    start_axi_o	=> start_axi_s,
        block_type_00_axi_o	=> block_type_00_axi_s,
        block_type_01_axi_o	=> block_type_01_axi_s,
        block_type_10_axi_o	=> block_type_10_axi_s,
        block_type_11_axi_o	=> block_type_11_axi_s,
        gr_axi_o	=> gr_axi_s,
        ch_axi_o	=> ch_axi_s,
        ready_axi_i	=> ready_axi_s,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
    imdct_ins: imdct
    port map( clk   => s00_axi_aclk,
		      reset	=> s00_axi_aresetn,
		      start => start_axi_s,
        	  ready => ready_axi_s,
        	  din_a   => dout_bram_a,
        	  dout_a  => din_bram_a,
			  addr_a  => addr_bram_a,
			  we_a    => we_bram_a,
			  en_a    => en_bram_a,
        	  din_b   => dout_bram_b,
        	  dout_b  => din_bram_b,
			  addr_b  => addr_bram_b,
			  we_b    => we_bram_b,
			  en_b    => en_bram_b,
			  block_type_00 => block_type_00_axi_s,
			  block_type_01 => block_type_01_axi_s,
			  block_type_10 => block_type_10_axi_s,
			  block_type_11 => block_type_11_axi_s,
			  gr    => gr_axi_s,
			  ch    => ch_axi_s
			);
	-- User logic ends

end arch_imp;
