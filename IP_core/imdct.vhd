----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2022 10:05:06 PM
-- Design Name: 
-- Module Name: imdct - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity imdct is
    generic (
	       WIDTH : integer := 32;
	       WADDR   : integer := 12
    );

  	port( 	clk   : in  std_logic;		-- clock input signal
        	reset : in  std_logic;		-- reset signal (1 = reset)
        	start : in  std_logic;		-- start=1 means that this block is activated
        	ready : out std_logic;		-- generate a done signal for one clock pulse when finished
        	din_a   : in  std_logic_vector( WIDTH-1 downto 0 );	-- signals from memory
        	dout_a  : out std_logic_vector( WIDTH-1 downto 0 );
			addr_a  : out std_logic_vector( 32-1 downto 0 );
			we_a    : out std_logic;
			en_a    : out std_logic;
			din_b   : in  std_logic_vector( WIDTH-1 downto 0 );	-- signals from memory
        	dout_b  : out std_logic_vector( WIDTH-1 downto 0 );
			addr_b  : out std_logic_vector( WIDTH-1 downto 0 );
			we_b    : out std_logic;
			en_b    : out std_logic;
			block_type_00 : in std_logic_vector( 1 downto 0 );
			block_type_01 : in std_logic_vector( 1 downto 0 );
			block_type_10 : in std_logic_vector( 1 downto 0 );
			block_type_11 : in std_logic_vector( 1 downto 0 );
			gr    : in std_logic;
			ch    : in std_logic
    	);
end imdct;

architecture Behavioral of imdct is

    type state_type is ( idle, get_n, get_half_n, rst_xi_s, send_addr, calc_1, calc_1_v2, calc_2, get_sine_block, windowing_samples, windowing_samples_v2,
                         judge1, judge2, addr_temp_block, get_temp_block, calc_addr_sample_block_step_1, calc_sample_block_step_1,
                         get_temp_block_step_2,calc_sample_block_step_2,addr_temp_block_v1_step_3, get_temp_block_v1_step_3,
                         addr_temp_block_v2_step_3, get_temp_block_v2_step_3, calc_sample_block_step_3, calc_sample_block_step_3_v2,addr_temp_block_v1_step_4,
                         get_temp_block_v1_step_4, addr_temp_block_v2_step_4, get_temp_block_v2_step_4, calc_sample_block_step_4, calc_sample_block_step_4_v2,
                         addr_temp_block_step_5, calc_sample_block_step_5, calc_sample_block_step_6,
                         overlap_addr_sample_block, overlap_get_sample_block, overlap_addr_prev_sample, overlap_get_prev_sample,
                         overlap_send_data, overlap_send_data_v2, overlap_addr_sample_block_step_2, overlap_get_sample_block_step_2, overlap_prev_samples_addr,
                         overlap_prev_samples_send_data, judge3, send_data_to_adder, reset_prev_samples, reset_sample_tamp, 
                         mul_1, mul_2, mul_3, mul_4, mul_5, mul_6, adder_1, adder_2, adder_3, adder_4, adder_5, adder_6, adder_7, adder_8, adder_9, adder_10, adder_11,
                         adder_12, adder_13, adder_14 );
  	
  	signal present_state,next_state: state_type;

  	signal gr_s : std_logic;
  	signal ch_s : std_logic;

    --counter
    signal block_s, win_s, i_s, k_s, x_s : integer;
    signal block_s_next, win_s_next, i_s_next, k_s_next, x_s_next : integer;
    signal win_temp_s, win_temp_s_next : integer;
    signal i_adder_s, i_adder_s_next : integer;
    signal smp_s , smp_s_next : integer;

    signal n_s, n_s_next : integer;
    signal half_n_s , half_n_s_next : integer;
    signal bram_adr_pointer, bram_adr_pointer_next : integer;
    signal bram_pointer, bram_pointer_next : std_logic;
    
    signal block_type_s, block_type_s_next : std_logic_vector( 1 downto 0 );
    
    signal xi_s, xi_s_next: std_logic_vector(WIDTH-1 downto 0);

    -- dout from ROM memory
    signal dout_s_b_s, dout_s_b_s_next : std_logic_vector(WIDTH-1 downto 0);
    
    --cos_rom_0
    signal address_cos_0_s : std_logic_vector(10-1 downto 0);
    signal dout_cos_0_s : std_logic_vector(WIDTH-1 downto 0);

    --cos_rom_1
    signal address_cos_1_s : std_logic_vector(8-1 downto 0);
    signal dout_cos_1_s : std_logic_vector(WIDTH-1 downto 0);
    
    --sine_block_rom_1
    signal address_s_b_1_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_1_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_2
    signal address_s_b_2_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_2_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_3
    signal address_s_b_3_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_3_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_4
    signal address_s_b_4_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_4_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sample_block_bram
    signal en_sample_block_s, we_sample_block_s : std_logic;
	signal addr_sample_block_s : std_logic_vector(WADDR-1 downto 0);
	signal do_sample_block_s : std_logic_vector(WIDTH-1 downto 0);
    signal di_sample_block_s : std_logic_vector(WIDTH-1 downto 0);
	signal sample_block_s, sample_block_s_next : std_logic_vector(WIDTH-1 downto 0);
    
     --temp_block_bram
    signal en_temp_block_s, we_temp_block_s : std_logic;
	signal addr_temp_block_s : std_logic_vector(WADDR-1 downto 0);
	signal di_temp_block_s, do_temp_block_s : std_logic_vector(WIDTH-1 downto 0);
    signal temp_block_value_1_s, temp_block_value_1_s_next : std_logic_vector(WIDTH-1 downto 0);
    signal temp_block_value_2_s, temp_block_value_2_s_next : std_logic_vector(WIDTH-1 downto 0);

     --prev_samples_0
    signal en_prev_samples_0_s, we_prev_samples_0_s : std_logic;
	signal addr_prev_samples_0_s : std_logic_vector(WADDR-1 downto 0);
	signal di_prev_samples_0_s, do_prev_samples_0_s : std_logic_vector(WIDTH-1 downto 0);
    
     --prev_samples_1
    signal en_prev_samples_1_s, we_prev_samples_1_s : std_logic;
	signal addr_prev_samples_1_s : std_logic_vector(WADDR-1 downto 0);
	signal di_prev_samples_1_s, do_prev_samples_1_s : std_logic_vector(WIDTH-1 downto 0);
    
    signal prev_samples_s, prev_samples_s_next : std_logic_vector(WIDTH-1 downto 0);
    
    signal z_temp, z_temp_next : std_logic_vector(WIDTH-1 downto 0);
    
    -- float point adder
    signal x_a                      ,  x_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    signal y_a                      ,  y_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    signal z_a                      ,  z_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    signal x_mantissa_a             ,  x_mantissa_a_next           : STD_LOGIC_VECTOR (22 downto 0);
	signal x_exponent_a             ,  x_exponent_a_next           : STD_LOGIC_VECTOR (7 downto 0);
	signal x_sign_a                 ,  x_sign_a_next               : STD_LOGIC;
	signal y_mantissa_a             ,  y_mantissa_a_next           : STD_LOGIC_VECTOR (22 downto 0);
	signal y_exponent_a             ,  y_exponent_a_next           : STD_LOGIC_VECTOR (7 downto 0);
	signal y_sign_a                 ,  y_sign_a_next               : STD_LOGIC;
	signal z_mantissa_a             ,  z_mantissa_a_next           : STD_LOGIC_VECTOR (22 downto 0);
	signal z_exponent_a             ,  z_exponent_a_next           : STD_LOGIC_VECTOR (7 downto 0);
	signal z_sign_a                 ,  z_sign_a_next               : STD_LOGIC;
	signal exponent_diff_a          ,  exponent_diff_a_next        : STD_LOGIC_VECTOR (8 downto 0);
	signal A_mantissa_a             ,  A_mantissa_a_next           : STD_LOGIC_VECTOR (22 downto 0);
	signal B_mantissa_a             ,  B_mantissa_a_next           : STD_LOGIC_VECTOR (22 downto 0);
	signal C_exponent_a             ,  C_exponent_a_next           : STD_LOGIC_VECTOR (7 downto 0);
	signal final_exponent_a         ,  final_exponent_a_next       : STD_LOGIC_VECTOR (8 downto 0);
	signal A_sign_a                 ,  A_sign_a_next               : STD_LOGIC;
	signal SB_mantissa_a            ,  SB_mantissa_a_next          : STD_LOGIC_VECTOR (24 downto 0);
	signal add_input_B_a            ,  add_input_B_a_next          : STD_LOGIC_VECTOR (25 downto 0);
	signal cin_a                    ,  cin_a_next                  : STD_LOGIC;
	signal mantissa_sum_a           ,  mantissa_sum_a_next         : STD_LOGIC_VECTOR (25 downto 0);
	signal aux_a                    ,  aux_a_next                  : STD_LOGIC;
	signal final_shift_a            ,  final_shift_a_next          : STD_LOGIC_VECTOR (4 downto 0);
	signal shifted_mantissa_sum_a   ,  shifted_mantissa_sum_a_next : STD_LOGIC_VECTOR (23 downto 0);
	signal adder_location           ,  adder_location_next         : integer;
    
    -- float point multiplication
    signal x_m             , x_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal y_m             , y_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal z_m             , z_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal x_mantissa_m    , x_mantissa_m_next   : STD_LOGIC_VECTOR (22 downto 0);
	signal x_exponent_m    , x_exponent_m_next   : STD_LOGIC_VECTOR (7 downto 0);
	signal x_sign_m        , x_sign_m_next       : STD_LOGIC;
	signal y_mantissa_m    , y_mantissa_m_next   : STD_LOGIC_VECTOR (22 downto 0);
	signal y_exponent_m    , y_exponent_m_next   : STD_LOGIC_VECTOR (7 downto 0);
	signal y_sign_m        , y_sign_m_next       : STD_LOGIC;
	signal z_mantissa_m    , z_mantissa_m_next   : STD_LOGIC_VECTOR (22 downto 0);
	signal z_exponent_m    , z_exponent_m_next   : STD_LOGIC_VECTOR (7 downto 0);
	signal z_sign_m        , z_sign_m_next       : STD_LOGIC;
	signal aux_m           , aux_m_next          : STD_LOGIC;
	signal aux2_m          , aux2_m_next         : STD_LOGIC_VECTOR (47 downto 0);
	signal exponent_sum_m  , exponent_sum_m_next : STD_LOGIC_VECTOR (8 downto 0);    
	signal mul_location    ,  mul_location_next  : integer;
        
    component cos_rom
        port(
            address_cos_0 : in  std_logic_vector(10-1 downto 0);
            dout_cos_0   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
 
    component cos_rom_1
        port(
            address_cos_1 : in  std_logic_vector(8-1 downto 0);
            dout_cos_1   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component; 
    
    component sine_block_rom_1
        port(
            address_s_b_1 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_1   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;  
    
    component sine_block_rom_2
        port(
            address_s_b_2 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_2   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    
    component sine_block_rom_3
        port(
            address_s_b_3 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_3   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component; 
    
    component sine_block_rom_4
        port(
            address_s_b_4 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_4   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;          

    component sample_block_bram
        port(
            clk_sample_block : in std_logic;
            reset_sample_block: in std_logic;
	        en_sample_block : in std_logic;
	        we_sample_block : in std_logic;
	        addr_sample_block : in std_logic_vector(WADDR-1 downto 0);
	        di_sample_block : in std_logic_vector(WIDTH-1 downto 0);
	        do_sample_block : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component temp_block_bram
        port(
            clk_temp_block : in std_logic;
            reset_temp_block: in std_logic;
	        en_temp_block : in std_logic;
	        we_temp_block : in std_logic;
	        addr_temp_block : in std_logic_vector(WADDR-1 downto 0);
	        di_temp_block : in std_logic_vector(WIDTH-1 downto 0);
	        do_temp_block : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component prev_samples_0
        port(
	        clk_prev_samples_0   : in std_logic;
            reset_prev_samples_0 : in std_logic;
	        en_prev_samples_0    : in std_logic;
	        we_prev_samples_0    : in std_logic;
	        addr_prev_samples_0  : in std_logic_vector(WADDR-1 downto 0);
	        di_prev_samples_0    : in std_logic_vector(WIDTH-1 downto 0);
	        do_prev_samples_0    : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    
    component prev_samples_1
        port(
            clk_prev_samples_1   : in std_logic;
            reset_prev_samples_1 : in std_logic;
	        en_prev_samples_1    : in std_logic;
	        we_prev_samples_1    : in std_logic;
	        addr_prev_samples_1  : in std_logic_vector(WADDR-1 downto 0);
	        di_prev_samples_1    : in std_logic_vector(WIDTH-1 downto 0);
	        do_prev_samples_1    : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

begin
    
   c0: cos_rom
       port map(
	       address_cos_0 => address_cos_0_s,
	       dout_cos_0    => dout_cos_0_s
       );    

   c1: cos_rom_1
       port map(
	       address_cos_1 => address_cos_1_s,
	       dout_cos_1    => dout_cos_1_s
       );   

   c2: sine_block_rom_1
       port map(
	       address_s_b_1 => address_s_b_1_s,
	       dout_s_b_1    => dout_s_b_1_s
       );
        
   c3: sine_block_rom_2
       port map(
	       address_s_b_2 => address_s_b_2_s,
	       dout_s_b_2    => dout_s_b_2_s
       );
        
   c4: sine_block_rom_3
       port map(
	       address_s_b_3 => address_s_b_3_s,
	       dout_s_b_3    => dout_s_b_3_s
       );
        
   c5: sine_block_rom_4
       port map(
	       address_s_b_4 => address_s_b_4_s,
	       dout_s_b_4    => dout_s_b_4_s
       );

    c6: sample_block_bram
        port map(
            clk_sample_block   => clk,
            reset_sample_block => reset,
	        en_sample_block    => en_sample_block_s,
	        we_sample_block    => we_sample_block_s,
	        addr_sample_block  => addr_sample_block_s,
	        di_sample_block    => di_sample_block_s,
	        do_sample_block    => do_sample_block_s
        );

    c7: temp_block_bram
        port map(
            clk_temp_block   => clk,
            reset_temp_block => reset,
	        en_temp_block    => en_temp_block_s,
	        we_temp_block    => we_temp_block_s,
	        addr_temp_block  => addr_temp_block_s,
	        di_temp_block    => di_temp_block_s,
	        do_temp_block    => do_temp_block_s
        );

    c8: prev_samples_0
        port map(
            clk_prev_samples_0   => clk,
            reset_prev_samples_0 => reset,
	        en_prev_samples_0    => en_prev_samples_0_s,
	        we_prev_samples_0    => we_prev_samples_0_s,
	        addr_prev_samples_0  => addr_prev_samples_0_s,
	        di_prev_samples_0    => di_prev_samples_0_s,
	        do_prev_samples_0    => do_prev_samples_0_s
        );

    c9: prev_samples_1
        port map(
            clk_prev_samples_1   => clk,
            reset_prev_samples_1 => reset,
	        en_prev_samples_1    => en_prev_samples_1_s,
	        we_prev_samples_1    => we_prev_samples_1_s,
	        addr_prev_samples_1  => addr_prev_samples_1_s,
	        di_prev_samples_1    => di_prev_samples_1_s,
	        do_prev_samples_1    => do_prev_samples_1_s
        );

    process(clk, reset)  
    begin
          	if reset = '0' then               
	  			present_state <= idle;
	  			n_s <= 0;
                half_n_s <= 0;
                block_type_s <= (others => '0');
                bram_adr_pointer <= 0;
                bram_pointer <= '0';
                win_temp_s <= 0;
                xi_s <= (others => '0');
                sample_block_s <= (others => '0');
                prev_samples_s <= (others => '0');
                temp_block_value_1_s <= (others => '0');
                temp_block_value_2_s <= (others => '0');
	  			dout_s_b_s <= (others => '0');
	  			z_temp <= (others => '0');
	            x_mantissa_m   <= (others => '0');
                x_exponent_m   <= (others => '0');
                x_sign_m       <= '0';
                y_mantissa_m   <= (others => '0');
                y_exponent_m   <= (others => '0');
                y_sign_m       <= '0';
                z_mantissa_m   <= (others => '0');
                z_exponent_m   <= (others => '0');
                z_sign_m       <= '0';
                aux_m          <= '0';
                aux2_m         <= (others => '0');
                exponent_sum_m <= (others => '0');
                mul_location   <= 0;
	  			x_mantissa_a            <= (others => '0');
                x_exponent_a            <= (others => '0');
                x_sign_a                <= '0';
                y_mantissa_a            <= (others => '0');
                y_exponent_a            <= (others => '0');
                y_sign_a                <= '0';
                z_mantissa_a            <= (others => '0');
                z_exponent_a            <= (others => '0');
                z_sign_a                <= '0';
                exponent_diff_a         <= (others => '0');
                A_mantissa_a            <= (others => '0');
                B_mantissa_a            <= (others => '0');
                C_exponent_a            <= (others => '0');
                final_exponent_a        <= (others => '0');
                A_sign_a                <= '0';
                SB_mantissa_a           <= (others => '0');
                add_input_B_a           <= (others => '0');
                cin_a                   <= '0';
                mantissa_sum_a          <= (others => '0');
                aux_a                   <= '0';
                final_shift_a           <= (others => '0');
                shifted_mantissa_sum_a  <= (others => '0');
                adder_location        <= 0;
	  			
     	   	elsif (rising_edge(clk)) then
          		present_state <= next_state;
          		n_s <= n_s_next;
                half_n_s <= half_n_s_next;
                block_type_s <= block_type_s_next;
                bram_adr_pointer <= bram_adr_pointer_next;
                bram_pointer <= bram_pointer_next; 
                win_temp_s <= win_temp_s_next;
                xi_s <= xi_s_next;
                sample_block_s <= sample_block_s_next;
                prev_samples_s <= prev_samples_s_next;
                temp_block_value_1_s <= temp_block_value_1_s_next;
                temp_block_value_2_s <= temp_block_value_2_s_next;
          		dout_s_b_s <= dout_s_b_s_next;
          		z_temp <= z_temp_next;
          		x_m             <= x_m_next;
                y_m             <= y_m_next;
                z_m             <= z_m_next;
          		x_mantissa_m    <= x_mantissa_m_next;
                x_exponent_m    <= x_exponent_m_next;  
                x_sign_m        <= x_sign_m_next;      
                y_mantissa_m    <= y_mantissa_m_next;  
                y_exponent_m    <= y_exponent_m_next;  
                y_sign_m        <= y_sign_m_next;     
                z_mantissa_m    <= z_mantissa_m_next;
                z_exponent_m    <= z_exponent_m_next;
                z_sign_m        <= z_sign_m_next;
                aux_m           <= aux_m_next;
                aux2_m          <= aux2_m_next;
                exponent_sum_m  <= exponent_sum_m_next;
                mul_location    <=  mul_location_next;
          		x_a                      <= x_a_next;
                y_a                      <= y_a_next;
                z_a                      <= z_a_next;
          		x_mantissa_a             <= x_mantissa_a_next;          
                x_exponent_a             <= x_exponent_a_next;          
                x_sign_a                 <= x_sign_a_next;              
                y_mantissa_a             <= y_mantissa_a_next;          
                y_exponent_a             <= y_exponent_a_next;          
                y_sign_a                 <= y_sign_a_next;              
                z_mantissa_a             <= z_mantissa_a_next;          
                z_exponent_a             <= z_exponent_a_next;          
                z_sign_a                 <= z_sign_a_next;              
                exponent_diff_a          <= exponent_diff_a_next;       
                A_mantissa_a             <= A_mantissa_a_next;          
                B_mantissa_a             <= B_mantissa_a_next;          
                C_exponent_a             <= C_exponent_a_next;          
                final_exponent_a         <= final_exponent_a_next;      
                A_sign_a                 <= A_sign_a_next;              
                SB_mantissa_a            <= SB_mantissa_a_next;         
                add_input_B_a            <= add_input_B_a_next;         
                cin_a                    <= cin_a_next;                 
                mantissa_sum_a           <= mantissa_sum_a_next;        
                aux_a                    <= aux_a_next;                 
                final_shift_a            <= final_shift_a_next;         
                shifted_mantissa_sum_a   <= shifted_mantissa_sum_a_next;
          		adder_location         <= adder_location_next;
			end if;
    end process;

    -- counter   
    process(clk, reset)
    begin
          	if reset = '0' then               
	  			block_s <= 0;
	  			win_s   <= 0;
	  			i_s     <= 0;
	  			k_s     <= 0;
	  			x_s     <= 0;
	  			smp_s <= 0;
                i_adder_s <= 0;
     	   	elsif (rising_edge(clk)) then
          		block_s <= block_s_next;
          		win_s   <= win_s_next;
          		i_s     <= i_s_next;
          		k_s     <= k_s_next;
          		x_s     <= x_s_next;
          		smp_s <= smp_s_next;
                i_adder_s <= i_adder_s_next;
			end if;
    end process;

    process( present_state, block_s, win_s, i_s, k_s, x_s, smp_s, start,block_type_s, block_type_00, block_type_01, block_type_10, block_type_11, n_s, gr, ch, bram_adr_pointer, bram_pointer, half_n_s, din_a, din_b,
             dout_cos_0_s, xi_s, k_s_next, dout_s_b_1_s, dout_s_b_2_s, dout_s_b_3_s, dout_s_b_4_s,
             dout_s_b_s, i_s_next, win_s_next, win_temp_s, do_sample_block_s, do_temp_block_s, temp_block_value_1_s,
             temp_block_value_2_s, do_prev_samples_0_s, do_prev_samples_1_s,  sample_block_s, prev_samples_s, block_s_next, 
             smp_s_next, dout_cos_1_s, z_temp, x_m, y_m, z_m, x_mantissa_m, x_exponent_m, x_sign_m, y_mantissa_m, y_exponent_m, y_sign_m, z_mantissa_m, z_exponent_m, z_sign_m,
             aux_m, aux2_m, exponent_sum_m, x_a, y_a, z_a, x_mantissa_a, x_exponent_a, x_sign_a, y_mantissa_a, y_exponent_a, y_sign_a ,z_mantissa_a, z_exponent_a, z_sign_a, exponent_diff_a,       
             A_mantissa_a, B_mantissa_a, C_exponent_a, final_exponent_a, A_sign_a, SB_mantissa_a, add_input_B_a, cin_a, mantissa_sum_a, aux_a, final_shift_a,
             shifted_mantissa_sum_a, adder_location, mul_location, i_adder_s )
    begin
    
        --default:
        next_state  <= present_state;
        block_s_next <= block_s;
        win_s_next <= win_s;
        i_s_next <= i_s;
        k_s_next <= k_s;
        x_s_next <= x_s;
        smp_s_next <= smp_s;
        n_s_next <= n_s;
        half_n_s_next <= half_n_s;
        block_type_s_next <= block_type_s;
        bram_adr_pointer_next <= bram_adr_pointer;
        bram_pointer_next <= bram_pointer;
        win_temp_s_next <= win_temp_s;
        xi_s_next <= xi_s;
        sample_block_s_next <= sample_block_s;
        prev_samples_s_next <= prev_samples_s;
        temp_block_value_1_s_next <= temp_block_value_1_s;
        temp_block_value_2_s_next <= temp_block_value_2_s;
        z_temp_next <= z_temp;
        en_a <= '0';
        we_a <= '0';
        addr_a <= (others => '0');
        dout_a <= (others => '0');
        en_b <= '0';
        we_b <= '0';
        addr_b <= (others => '0');
        dout_b <= (others => '0');
        dout_s_b_s_next <= dout_s_b_s;
        en_temp_block_s <= '0';
        we_temp_block_s <= '0';
        addr_temp_block_s <= (others => '0');
        di_temp_block_s <= (others => '0');
        en_sample_block_s <= '0';
        we_sample_block_s <= '0';
        addr_sample_block_s <= (others => '0');
        di_sample_block_s <= (others => '0');
        en_prev_samples_0_s <= '0';
        we_prev_samples_0_s <= '0';
        addr_prev_samples_0_s <= (others => '0');
        di_prev_samples_0_s <= (others => '0');
        en_prev_samples_1_s <= '0';
        we_prev_samples_1_s <= '0';
        addr_prev_samples_1_s <= (others => '0');
        di_prev_samples_1_s <= (others => '0');
        address_cos_0_s <= (others => '0');
        address_cos_1_s <= (others => '0');
        address_s_b_1_s <= (others => '0');
        address_s_b_2_s <= (others => '0');
        address_s_b_3_s <= (others => '0');
        address_s_b_4_s <= (others => '0');
        x_m_next            <= x_m;
        y_m_next            <= y_m;
        z_m_next            <= z_m;
        x_mantissa_m_next   <= x_mantissa_m;
        x_exponent_m_next   <= x_exponent_m;
        x_sign_m_next       <= x_sign_m;
        y_mantissa_m_next   <= y_mantissa_m;
        y_exponent_m_next   <= y_exponent_m;
        y_sign_m_next       <= y_sign_m;
        z_mantissa_m_next   <= z_mantissa_m;
        z_exponent_m_next   <= z_exponent_m;
        z_sign_m_next       <= z_sign_m;
        aux_m_next          <= aux_m;
        aux2_m_next         <= aux2_m;
        exponent_sum_m_next <= exponent_sum_m; 
        mul_location_next   <=  mul_location;
        x_a_next                     <= x_a;
        y_a_next                     <= y_a;
        z_a_next                     <= z_a;
        x_mantissa_a_next            <= x_mantissa_a;
        x_exponent_a_next            <= x_exponent_a;
        x_sign_a_next                <= x_sign_a;
        y_mantissa_a_next            <= y_mantissa_a;
        y_exponent_a_next            <= y_exponent_a;
        y_sign_a_next                <= y_sign_a;
        z_mantissa_a_next            <= z_mantissa_a;
        z_exponent_a_next            <= z_exponent_a;
        z_sign_a_next                <= z_sign_a;
        exponent_diff_a_next         <= exponent_diff_a;
        A_mantissa_a_next            <= A_mantissa_a;
        B_mantissa_a_next            <= B_mantissa_a;
        C_exponent_a_next            <= C_exponent_a;
        final_exponent_a_next        <= final_exponent_a;
        A_sign_a_next                <= A_sign_a;
        SB_mantissa_a_next           <= SB_mantissa_a;
        add_input_B_a_next           <= add_input_B_a;
        cin_a_next                   <= cin_a;
        mantissa_sum_a_next          <= mantissa_sum_a;
        aux_a_next                   <= aux_a;
        final_shift_a_next           <= final_shift_a;
        shifted_mantissa_sum_a_next  <= shifted_mantissa_sum_a;
        i_adder_s_next             <= i_adder_s;
        adder_location_next        <= adder_location;
        ready <= '0';
        
        case present_state is
            when idle =>
                ready <= '1';
                
                if (start = '1') then
                    block_s_next <= 0;
                    win_s_next <= 0;
                    i_s_next <= 0;
                    k_s_next <= 0;
                    x_s_next <= 0;
                    smp_s_next <= 0;
                    i_adder_s_next <= 0;
                    next_state <= reset_prev_samples;
                else
                    next_state <= idle;
                end if;
        
            when reset_prev_samples =>
                en_prev_samples_0_s <= '1';
                we_prev_samples_0_s <= '1';
                addr_prev_samples_0_s <=  conv_std_logic_vector( i_s , WADDR );
                di_prev_samples_0_s <= conv_std_logic_vector( 0 , WIDTH );
                
                en_prev_samples_1_s <= '1';
                we_prev_samples_1_s <= '1';
                addr_prev_samples_1_s <=  conv_std_logic_vector( i_s , WADDR );
                di_prev_samples_1_s <= conv_std_logic_vector( 0 , WIDTH );
                
                if( i_s < 575 ) then
                    i_s_next <= i_s + 1;
                    next_state <= reset_prev_samples;
                else
                    i_s_next <= 0;
                   next_state <= reset_sample_tamp;
                end if;
                
            when reset_sample_tamp =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s , WADDR );
                di_sample_block_s <= conv_std_logic_vector( 0 , WIDTH );
                
                en_temp_block_s <= '1';
                we_temp_block_s <= '1';
                addr_temp_block_s <=  conv_std_logic_vector( i_s , WADDR );
                di_temp_block_s <= conv_std_logic_vector( 0 , WIDTH );
                
                if( i_s < 35 ) then
                    i_s_next <= i_s + 1;
                    next_state <= reset_sample_tamp;
                else
                    i_s_next <= 0;
                    if(gr = '0' and ch = '0') then
                        block_type_s_next <= block_type_00;
                    elsif (gr = '0' and ch = '1') then
                        block_type_s_next <= block_type_01; 
                    elsif (gr = '1' and ch = '0') then
                        block_type_s_next <= block_type_10;
                    else 
                        block_type_s_next <= block_type_11;
                    end if;
                        next_state <= get_n;
                 end if;    
                
            when get_n =>
            
                if( block_type_s = "10" ) then
                    n_s_next <= 12;
                else
                    n_s_next <= 36;            
                end if;
                
                next_state <= get_half_n;
                
            when get_half_n =>
                half_n_s_next <= n_s / 2;
                
                if( gr = '0' and ch = '0' ) then
                    bram_adr_pointer_next <= 0;
                    bram_pointer_next <= '0';
                elsif( gr = '0' and ch = '1' ) then
                    bram_adr_pointer_next <= 576;
                    bram_pointer_next <= '0';
                elsif( gr = '1' and ch = '0' ) then
                    bram_adr_pointer_next <= 0;
                    bram_pointer_next <= '1';
                elsif( gr = '1' and ch = '1' ) then
                    bram_adr_pointer_next <= 576;
                    bram_pointer_next <= '1';
                end if;
                
                next_state <= rst_xi_s;
                
            when rst_xi_s =>
                xi_s_next <= conv_std_logic_vector( 0 , WIDTH );
                next_state <= calc_1;
                
            when calc_1 =>
                if( bram_pointer = '0' ) then    
                    en_a <= '1';
                    we_a <= '0';
                    addr_a <= conv_std_logic_vector( ( ( bram_adr_pointer + ( 18 * block_s + half_n_s * win_s + k_s ) ) * 4 ), 32 );
                    x_m_next <= din_a;
                elsif( bram_pointer = '1' ) then
                    en_b <= '1';
                    we_b <= '0';
                    addr_b <= conv_std_logic_vector( ( ( bram_adr_pointer + ( 18 * block_s + half_n_s * win_s + k_s ) ) * 4 ), 32 );
                    x_m_next <= din_b;
                end if;
                
                if ( block_type_s = "10" ) then
                    address_cos_1_s <= conv_std_logic_vector( k_s + ( i_s * 6 ) , 8 );
                    y_m_next <= dout_cos_1_s;
                else
                    address_cos_0_s <= conv_std_logic_vector( k_s + ( i_s * 18 ) , 10 );
                    y_m_next <= dout_cos_0_s;
                end if;
                mul_location_next <= 1;
                next_state <= mul_1;
                
            when calc_1_v2 =>
                x_a_next <= z_m; 
                y_a_next <= xi_s;
                adder_location_next <= 1;
                
                next_state <= adder_1;
            
            when calc_2 =>
            
                xi_s_next <= z_a;
                
                if( k_s < ( half_n_s - 1 ) ) then
                    k_s_next <= k_s + 1;
                    next_state <= calc_1;
                else
                    next_state <= get_sine_block;
                    k_s_next <= 0;
                end if;
                
            when get_sine_block =>
                    
                if( block_type_s = "00" ) then
                    address_s_b_1_s <= conv_std_logic_vector( i_s , WADDR );
                    dout_s_b_s_next <= dout_s_b_1_s;
                elsif( block_type_s = "01" ) then
                    address_s_b_2_s <= conv_std_logic_vector( i_s , WADDR );
                    dout_s_b_s_next <= dout_s_b_2_s;
                elsif( block_type_s = "10" ) then
                    address_s_b_3_s <= conv_std_logic_vector( i_s , WADDR );
                    dout_s_b_s_next <= dout_s_b_3_s;
                elsif( block_type_s = "11" ) then
                    address_s_b_4_s <= conv_std_logic_vector( i_s , WADDR );
                    dout_s_b_s_next <= dout_s_b_4_s;
                end if; 
                
                next_state <= windowing_samples;
                
            when windowing_samples =>
                x_m_next <= xi_s;
                y_m_next <= dout_s_b_s;
                mul_location_next <= 2;
                
                next_state <= mul_1;
            
            when windowing_samples_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( ( win_s * n_s + i_s ) , WADDR );
                di_sample_block_s <= z_m;                        
              
                if( i_s < ( n_s - 1 ) ) then
                    i_s_next <= i_s + 1;
                    next_state <= rst_xi_s;
                else
                    i_s_next <= 0;
                if( block_type_s = "10" ) then
                    win_temp_s_next <= 3;
                else 
                    win_temp_s_next <= 1;
                end if;
                    next_state <= judge1;
                end if;
            
            when judge1 =>
                if( win_s < ( win_temp_s - 1 ) ) then
                    win_s_next <= win_s + 1;
                    next_state <= rst_xi_s;
                else 
                    win_s_next <= 0;
                    next_state <= judge2;
                end if;    
            
            when judge2 =>
                if( block_type_s = "10" ) then
                    next_state <= addr_temp_block;
                else 
                    next_state <= overlap_addr_sample_block;
                end if;
            
            when addr_temp_block =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  conv_std_logic_vector( x_s, WADDR );
                next_state <= get_temp_block;
                
            when get_temp_block =>             
                en_temp_block_s <= '1';
                we_temp_block_s <= '1';
                addr_temp_block_s <=  conv_std_logic_vector( x_s, WADDR );

                di_temp_block_s <= do_sample_block_s;
                
                if ( x_s < ( 36 - 1) ) then
                    x_s_next <= x_s + 1;
                    next_state <= addr_temp_block;
                else
                    x_s_next <= 0;
                    i_s_next <= 0;
                    next_state <= calc_sample_block_step_1;
                end if;                

            when calc_sample_block_step_1 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= conv_std_logic_vector( 0, WIDTH );
                i_s_next <= i_s + 1;
                
                if ( i_s < (6 - 1) ) then    
                    next_state <= calc_sample_block_step_1;
                else
                    next_state <= get_temp_block_step_2;
                end if;    
    
            when get_temp_block_step_2 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 0 + i_s - 6 ), WADDR );
 
                next_state <= calc_sample_block_step_2;

            when calc_sample_block_step_2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= do_temp_block_s;
                i_s_next <= i_s + 1;
                
                if ( i_s < (12 - 1) ) then    
                    next_state <= get_temp_block_step_2;
                else
                    next_state <= addr_temp_block_v1_step_3;
                end if;

            when addr_temp_block_v1_step_3 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 0 + i_s - 6 ), WADDR );
                next_state <= get_temp_block_v1_step_3;

            when get_temp_block_v1_step_3 =>
                temp_block_value_1_s_next <= do_temp_block_s;next_state <= addr_temp_block_v2_step_3;                
 
            when addr_temp_block_v2_step_3 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 12 + i_s - 12 ), WADDR );
                next_state <= get_temp_block_v2_step_3;
 
            when get_temp_block_v2_step_3 =>
                temp_block_value_2_s_next <= do_temp_block_s;
                next_state <= calc_sample_block_step_3;             

            when calc_sample_block_step_3 =>
                x_a_next <= temp_block_value_1_s;
                y_a_next <= temp_block_value_2_s;
                adder_location_next <= 2;
                
                next_state <= adder_1;       

            when calc_sample_block_step_3_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= z_a;
                
                i_s_next <= i_s + 1;
                
                if ( i_s < (18 - 1) ) then
                    next_state <= addr_temp_block_v1_step_3;
                else
                    next_state <= addr_temp_block_v1_step_4;
                end if;     

            when addr_temp_block_v1_step_4 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 12 + i_s - 12 ), WADDR );
                next_state <= get_temp_block_v1_step_4;
                
            when get_temp_block_v1_step_4 =>
                temp_block_value_1_s_next <= do_temp_block_s;
            
                next_state <= addr_temp_block_v2_step_4;

            when addr_temp_block_v2_step_4 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 24 + i_s - 18 ), WADDR );
                next_state <= get_temp_block_v2_step_4;

            when get_temp_block_v2_step_4 =>
                temp_block_value_2_s_next <= do_temp_block_s;
                next_state <= calc_sample_block_step_4;             

            when calc_sample_block_step_4 =>
                x_a_next <= temp_block_value_1_s;
                y_a_next <= temp_block_value_2_s;
                adder_location_next <= 3;
                
                next_state <= adder_1;   
            
            when calc_sample_block_step_4_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= z_a;
                i_s_next <= i_s + 1;
                
                if ( i_s < (24 - 1) ) then
                    next_state <= addr_temp_block_v1_step_4;
                else
                    next_state <= addr_temp_block_step_5;
                end if;
    
            when addr_temp_block_step_5 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  conv_std_logic_vector( ( 24 + i_s - 18 ), WADDR );
                next_state <= calc_sample_block_step_5;
    
            when calc_sample_block_step_5 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= do_temp_block_s;
                i_s_next <= i_s + 1;
                
                if ( i_s < (30 - 1) ) then
                    next_state <= addr_temp_block_step_5;
                else
                    next_state <= calc_sample_block_step_6;
                end if;

            when calc_sample_block_step_6 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <= conv_std_logic_vector( i_s, WADDR );
                di_sample_block_s <= conv_std_logic_vector( 0, WIDTH );
                i_s_next <= i_s + 1;
                
                if ( i_s < (36 - 1) ) then
                    next_state <= calc_sample_block_step_6;
                else
                    i_s_next <= 0;
                    next_state <= overlap_addr_sample_block;
                end if;
            
            when overlap_addr_sample_block =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  conv_std_logic_vector( i_s, WADDR );
                next_state <= overlap_get_sample_block;
                
            when overlap_get_sample_block =>    
                sample_block_s_next <= do_sample_block_s;
                next_state <= overlap_addr_prev_sample;
            
            when overlap_addr_prev_sample =>
                en_prev_samples_0_s <= '1';
                we_prev_samples_0_s <= '0';
                addr_prev_samples_0_s <=  conv_std_logic_vector( i_s + smp_s, WADDR );
                
                en_prev_samples_1_s <= '1';
                we_prev_samples_1_s <= '0';
                addr_prev_samples_1_s <=  conv_std_logic_vector( i_s + smp_s, WADDR );
                next_state <= overlap_get_prev_sample;
            
            when overlap_get_prev_sample =>    
                
                if( ch = '0' ) then
                    prev_samples_s_next <= do_prev_samples_0_s;
                else
                    prev_samples_s_next <= do_prev_samples_1_s;
                end if;
                next_state <= overlap_send_data;
            
            when overlap_send_data =>
                x_a_next <= sample_block_s;
                y_a_next <= prev_samples_s;
                adder_location_next <= 4;
                
                next_state <= adder_1;   
                
            when overlap_send_data_v2 =>
                if( bram_pointer = '0' ) then    
                    en_a <= '1';
                    we_a <= '1';
                    addr_a <= conv_std_logic_vector( ( ( bram_adr_pointer + ( smp_s + i_s ) ) * 4 ), 32 );
                    dout_a <= z_a;
                elsif( bram_pointer = '1' ) then
                    en_b <= '1';
                    we_b <= '1';
                    addr_b <= conv_std_logic_vector( ( ( bram_adr_pointer + ( smp_s + i_s ) ) * 4 ), 32 );
                    dout_b <= z_a;
                end if;
                
                next_state <= overlap_addr_sample_block_step_2;
            
            when overlap_addr_sample_block_step_2 =>    
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  conv_std_logic_vector( 18 + i_s, WADDR );
                next_state <= overlap_get_sample_block_step_2;

            when overlap_get_sample_block_step_2 =>
                sample_block_s_next <= do_sample_block_s;
                next_state <= overlap_prev_samples_send_data;

            when overlap_prev_samples_send_data =>
                if( ch = '0' ) then
                    en_prev_samples_0_s <= '1';
                    we_prev_samples_0_s <= '1';
                    addr_prev_samples_0_s <=  conv_std_logic_vector( i_s + smp_s, WADDR );
                    di_prev_samples_0_s <= sample_block_s;
                else
                    en_prev_samples_1_s <= '1';
                    we_prev_samples_1_s <= '1';
                    addr_prev_samples_1_s <=  conv_std_logic_vector( i_s + smp_s, WADDR );
                    di_prev_samples_1_s <= sample_block_s;
                end if;
                
                if ( i_s < ( 18 - 1 ) ) then
                    i_s_next <= i_s + 1;
                    next_state <= overlap_addr_sample_block;
                else
                    i_s_next <= 0;
                    smp_s_next <= smp_s + 18; 
                    next_state <= judge3;
                end if;
            
            when judge3 =>
                if( block_s < ( 32 - 1 ) ) then
                    block_s_next <= block_s + 1;
                    next_state <= rst_xi_s;
                else 
                    win_s_next <= 0;
                    next_state <= idle;   
                end if; 
            
            when mul_1 =>    
                x_mantissa_m_next <= x_m(22 downto 0);
		        x_exponent_m_next <= x_m(30 downto 23);
		        x_sign_m_next     <= x_m(31);
		        y_mantissa_m_next <= y_m(22 downto 0);
		        y_exponent_m_next <= y_m(30 downto 23);
		        y_sign_m_next     <= y_m(31);
            
                next_state <= mul_2;
            
            when mul_2 =>  
                -- inf*0 is not tested (result would be NaN)
                if (x_exponent_m = 255 or y_exponent_m = 255) then 
                    -- inf*x or x*inf
                    z_exponent_m_next <= "11111111";
                    z_mantissa_m_next <= (others => '0');
                    z_sign_m_next <= x_sign_m xor y_sign_m;
                    next_state <= mul_6;
                elsif (x_exponent_m = 0 or y_exponent_m = 0) then 
                    -- 0*x or x*0
                    z_exponent_m_next <= (others => '0');
                    z_mantissa_m_next <= (others => '0');
                    z_sign_m_next <= '0';
                    next_state <= mul_6;
                else
                    aux2_m_next <= ('1' & x_mantissa_m) * ('1' & y_mantissa_m);
                    next_state <= mul_3;
                end if; 

            when mul_3 =>  
                -- args in Q23 result in Q46
                if (aux2_m(47) = '1') then 
                    -- >=2, shift left and add one to exponent
                    z_mantissa_m_next <= aux2_m(46 downto 24) + aux2_m(23); -- with rounding
                    aux_m_next <= '1';
                else
                    z_mantissa_m_next <= aux2_m(45 downto 23) + aux2_m(22); -- with rounding
                    aux_m_next <= '0';
                end if;

                 next_state <= mul_4;

            when mul_4 =>  
			    -- calculate exponent
			    exponent_sum_m_next <= ('0' & x_exponent_m) + ('0' & y_exponent_m) + aux_m - 127;
                next_state <= mul_5;
        
            when mul_5 => 
                if (exponent_sum_m(8) = '1') then 
		    		if (exponent_sum_m(7) = '0') then -- overflow
		    			z_exponent_m_next <= "11111111";
		    			z_mantissa_m_next <= (others => '0');
		    			z_sign_m_next <= x_sign_m xor y_sign_m;
		    		else 									-- underflow
		    			z_exponent_m_next <= (others => '0');
		    			z_mantissa_m_next <= (others => '0');
		    			z_sign_m_next <= '0';
		    		end if;
		    	else								  		 -- Ok
		    		z_exponent_m_next <= exponent_sum_m(7 downto 0);
		    		z_sign_m_next <= x_sign_m xor y_sign_m;
		    	end if;
                    
                next_state <= mul_6;
                    
            when mul_6 =>
                z_m_next(22 downto 0) <= z_mantissa_m;
                z_m_next(30 downto 23) <= z_exponent_m;
		        z_m_next(31) <= z_sign_m;
                    
		        if ( mul_location = 1) then
		            next_state <= calc_1_v2;
		        elsif ( mul_location = 2) then
		            next_state <= windowing_samples_v2;
                end if;
            
            when adder_1 =>
                x_mantissa_a_next <= x_a(22 downto 0);
		        x_exponent_a_next <= x_a(30 downto 23);
		        x_sign_a_next     <= x_a(31);
		        y_mantissa_a_next <= y_a(22 downto 0);
		        y_exponent_a_next <= y_a(30 downto 23);
		        y_sign_a_next     <= y_a(31);
		    
		        next_state <= adder_2;
		    
            when adder_2 =>
                if (x_exponent_a = "00000000") then -- x is zero
			        z_mantissa_a_next <= y_mantissa_a;
			        z_exponent_a_next <= y_exponent_a;
			        z_sign_a_next <= y_sign_a;
			        next_state <= adder_14;  
		        elsif (y_exponent_a = "00000000") then -- y is zero
			        z_mantissa_a_next <= x_mantissa_a;
			        z_exponent_a_next <= x_exponent_a;
			        z_sign_a_next <= x_sign_a;
			        next_state <= adder_14;
		        elsif (x_exponent_a = "11111111") then -- x is infinity
			        z_mantissa_a_next <= (others=>'0');
			        z_exponent_a_next <= (others=>'1');
			        z_sign_a_next <= x_sign_a;
			        next_state <= adder_14;
		        elsif (y_exponent_a = "11111111") then -- y is infinity
			        z_mantissa_a_next <= (others=>'0');
			        z_exponent_a_next <= (others=>'1');
			        z_sign_a_next <= y_sign_a;
			        next_state <= adder_14;
		        else
		            exponent_diff_a_next <= ('0' & x_exponent_a) - ('0' & y_exponent_a);
		            next_state <= adder_3;
		        end if;
        
            when adder_3 =>
                -- chose the higher exponent
			    if (exponent_diff_a(8) = '1') then
				    -- negative x_exponent < y_exponent
				    exponent_diff_a_next <= not exponent_diff_a + 1;
				    A_mantissa_a_next <= y_mantissa_a;
				    A_sign_a_next <= y_sign_a;
				    B_mantissa_a_next <= x_mantissa_a;
				    C_exponent_a_next <= y_exponent_a;
			    else
				    A_mantissa_a_next <= x_mantissa_a;
				    A_sign_a_next <= x_sign_a;
				    B_mantissa_a_next <= y_mantissa_a;
				    C_exponent_a_next <= x_exponent_a;
			    end if;
                next_state <= adder_4;
            
            when adder_4 =>
                SB_mantissa_a_next <= SHR('1' & B_mantissa_a & '0', exponent_diff_a);
		    	-- one extra bit in the right for rounding
		    	next_state <= adder_5;
                    
            when adder_5 =>
                if ( (x_sign_a xor y_sign_a) = '1') then -- subtraction
		    		cin_a_next <= '1';
		    		add_input_B_a_next <= not ('0' & SB_mantissa_a);
		    	else -- addition
		    		cin_a_next <= '0';
		    		add_input_B_a_next <= '0' & SB_mantissa_a;
		    	end if;
                next_state <= adder_6;
                    
            when adder_6 =>
                -- actual sum
		    	mantissa_sum_a_next <= ( "01" & A_mantissa_a & '0') + add_input_B_a + cin_a;
		    	next_state <= adder_7;
                    
            when adder_7 =>
                if (mantissa_sum_a(mantissa_sum_a'left)='1' and cin_a='1') then -- result is negative
		    		z_sign_a_next <= not A_sign_a;
		    		mantissa_sum_a_next <= not mantissa_sum_a + 1;
		    	else -- positive
		    		z_sign_a_next <= A_sign_a;
		    	end if;
                next_state <= adder_8;
        
            when adder_8 =>
                if (mantissa_sum_a(mantissa_sum_a'left)='1') then
		    		-- a shift right is required
		    		z_exponent_a_next <= C_exponent_a + 1;
		    		-- overflow is not required to test since inf 
		    		-- argumenst are taken separatly
                
		    		shifted_mantissa_sum_a_next <= mantissa_sum_a(mantissa_sum_a'left-1 downto 1);
		    		next_state <= adder_13;
		    	else
		    		-- find the first one
		    		aux_a_next <= '0';
		    		final_shift_a_next <= (others=>'0');  -- to avoid a latch
		    		i_adder_s_next <= mantissa_sum_a'left;
		    		next_state <= adder_9;
		    	end if;
                
	        when adder_9 =>
	            if (mantissa_sum_a(i_adder_s)='1' and aux_a='0') then
                    aux_a_next <= '1';
                    final_shift_a_next <= CONV_STD_LOGIC_VECTOR(mantissa_sum_a'left-1-i_adder_s,5);
                end if;
                
		        next_state <= adder_10;  
                
		    when adder_10 =>	
                
                if( i_adder_s > 0) then
                    i_adder_s_next <= i_adder_s - 1;
                    next_state <= adder_9;
                else 
                    i_adder_s_next <= 0;
                    next_state <= adder_11;
                end if;    
            
		    when adder_11 =>
		    		if (aux_a='0') then -- result is zero
		    			shifted_mantissa_sum_a_next <= (others=>'0');
		    			z_exponent_a_next <= (others=>'0');
		    			z_sign_a_next <= '0';
		    			next_state <= adder_13;
		    		else
		    			final_exponent_a_next <= ('0' & C_exponent_a) - final_shift_a;
		    			next_state <= adder_12;
		            end if; 
                    
		    when adder_12 =>
                if (final_exponent_a(8)='1') then -- underflow 
                    -- If final_exponent=0 then it is left unchanged and 
                    -- zero will have non zero mantissa.
                    shifted_mantissa_sum_a_next <= (others=>'0');
                    z_exponent_a_next <= (others=>'0');
                else
                    shifted_mantissa_sum_a_next <= SHL( mantissa_sum_a(mantissa_sum_a'left-2 downto 0), final_shift_a);
                    -- mantissa_sum has to extra bits to the left ( "01")
                    -- and one extra bit to the right for rounding 
                    z_exponent_a_next <= final_exponent_a(7 downto 0);
		    	end if;
		    	next_state <= adder_13;
                    
            when adder_13 =>
                z_mantissa_a_next <= shifted_mantissa_sum_a(shifted_mantissa_sum_a'left downto 1) + shifted_mantissa_sum_a(0); -- shift and round
                next_state <= adder_14;
            
            when adder_14 =>  
                z_a_next(22 downto 0) <= z_mantissa_a;
		        z_a_next(30 downto 23) <= z_exponent_a;
		        z_a_next(31) <= z_sign_a;
                    
		        if ( adder_location = 1) then
		            next_state <= calc_2;
		        elsif ( adder_location = 2) then
		            next_state <= calc_sample_block_step_3_v2;
		        elsif ( adder_location = 3) then
		            next_state <= calc_sample_block_step_4_v2;
		        elsif ( adder_location = 4) then
		            next_state <= overlap_send_data_v2;
		        end if;    
                
            when others => next_state <= idle;
        
        end case;
    end process;

end Behavioral;