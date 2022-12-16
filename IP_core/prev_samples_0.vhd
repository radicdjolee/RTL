----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2022 10:09:15 PM
-- Design Name: 
-- Module Name: prev_samples_0 - Behavioral
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

entity prev_samples_0 is
    generic (
	       WIDTH : integer := 32;
	       WADDR   : integer := 12
    );
    port (
	   clk_prev_samples_0   : in std_logic;
       reset_prev_samples_0 : in std_logic;
	   en_prev_samples_0    : in std_logic;
	   we_prev_samples_0    : in std_logic;
	   addr_prev_samples_0  : in std_logic_vector(WADDR-1 downto 0);
	   di_prev_samples_0    : in std_logic_vector(WIDTH-1 downto 0);
	   do_prev_samples_0    : out std_logic_vector(WIDTH-1 downto 0)
  );
end prev_samples_0;

architecture Behavioral of prev_samples_0 is
    type ram_type is array (575 downto 0) of std_logic_vector(WIDTH-1 downto 0);
    signal mem_s: ram_type;
begin

    process(clk_prev_samples_0) --sinhrono citanje
    begin
        if(rising_edge(clk_prev_samples_0)) then
            if(en_prev_samples_0 = '1') then
               if(we_prev_samples_0 = '1')then 
                   mem_s(to_integer(unsigned(addr_prev_samples_0))) <= di_prev_samples_0;
                end if;
                do_prev_samples_0 <= mem_s(to_integer(unsigned(addr_prev_samples_0)));
            end if;    
	    end if;
    end process;
 
end Behavioral;