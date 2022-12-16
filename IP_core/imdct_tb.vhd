----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2022 10:15:38 PM
-- Design Name: 
-- Module Name: imdct_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity imdct_tb is
--  Port ( );
end imdct_tb;

architecture Behavioral of imdct_tb is

        signal  clk_s   :  std_logic;		-- clock input signal
        signal	reset_s :  std_logic;		-- reset signal (1 = reset)
        signal	start_s :  std_logic;		-- start=1 means that this block is activated
        signal	ready_s :  std_logic;		-- generate a done signal for one clock pulse when finished
        signal	din_a_s   :  std_logic_vector(31 downto 0);	-- signals from memory
        signal	dout_a_s  :  std_logic_vector(31 downto 0);
		signal	addr_a_s  :  std_logic_vector(31 downto 0);
		signal	we_a_s    :  std_logic;
		signal	en_a_s    :  std_logic;
		signal	din_b_s   :  std_logic_vector(31 downto 0);	-- signals from memory
        signal	dout_b_s  :  std_logic_vector(31 downto 0);
		signal	addr_b_s  :  std_logic_vector(31 downto 0);
		signal	we_b_s    :  std_logic;
		signal	en_b_s    :  std_logic;
		signal  block_type_00_s :  std_logic_vector( 1 downto 0 );
		signal  block_type_01_s :  std_logic_vector( 1 downto 0 );
		signal  block_type_10_s :  std_logic_vector( 1 downto 0 );
		signal  block_type_11_s :  std_logic_vector( 1 downto 0 );
		signal	gr_s    :  std_logic;
		signal	ch_s    :  std_logic;

begin

    clk_gen:process
    begin
          clk_s <= '0', '1' after 100 ns;
          wait for 200 ns;
    end process;
        
        start_s <= '1';
        -- Apply system level reset
        reset_s <= '0', '1' after 2000 ns;
        

        block_type_00_s <= "00";
        block_type_01_s <= "00";
        block_type_10_s <= "00";
        block_type_11_s <= "00";       
        gr_s <= '0';
        ch_s <= '0';
 
    din_gen: process
    begin

         wait until reset_s = '0';
            --for i in 0 to 17 loop   
                din_a_s <= "01000000000000000000000000000000";
                din_b_s <= "01000000000000000000000000000000"; 
               -- wait until falling_edge(clk_s);
           -- end loop;        
     
    end process; 
   
   
    imdct: entity work.imdct(Behavioral)
    port map(  clk   => clk_s,
        	   reset => reset_s,
        	   start => start_s,
        	   ready => ready_s,
        	   din_a   => din_a_s,
        	   dout_a  => dout_a_s,
			   addr_a  => addr_a_s,
			   we_a    => we_a_s,
			   en_a    => en_a_s,
        	   din_b   => din_b_s,
        	   dout_b  => dout_b_s,
			   addr_b  => addr_b_s,
			   we_b    => we_b_s,
			   en_b    => en_b_s,
			   block_type_00 => block_type_00_s,
               block_type_01 => block_type_01_s,
               block_type_10 => block_type_10_s,
               block_type_11 => block_type_11_s,
			   gr    => gr_s,
			   ch    => ch_s
               );   
end Behavioral;
