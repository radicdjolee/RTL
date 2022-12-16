----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2022 10:08:27 PM
-- Design Name: 
-- Module Name: sample_block_bram - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sample_block_bram is
    generic (
	       WIDTH : integer := 32;
	       WADDR   : integer := 12
    );
    port (
	   clk_sample_block : in std_logic;
       reset_sample_block: in std_logic;
	   en_sample_block : in std_logic;
	   we_sample_block : in std_logic;
	   addr_sample_block : in std_logic_vector(WADDR-1 downto 0);
	   di_sample_block : in std_logic_vector(WIDTH-1 downto 0);
	   do_sample_block : out std_logic_vector(WIDTH-1 downto 0)
  );
end sample_block_bram;

architecture Behavioral of sample_block_bram is
    type ram_type is array (35 downto 0) of std_logic_vector(WIDTH-1 downto 0);
    signal mem_s: ram_type;
begin

    process(clk_sample_block) --sinhrono citanje
    begin
        if(rising_edge(clk_sample_block)) then
            if(en_sample_block = '1') then 
                if(we_sample_block='1')then 
                    mem_s(to_integer(unsigned(addr_sample_block))) <= di_sample_block;
                end if;
                do_sample_block <= mem_s(to_integer(unsigned(addr_sample_block)));  
            end if;
	    end if;
    end process;
 
end Behavioral;


