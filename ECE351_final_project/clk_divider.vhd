----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu, Ben Olson - molson5@utk.edu
-- ECE-351: Course Project - Greenhouse Monitor
-- Notes: Clock divider  
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity clk_divider is
   Port ( 
		rst: in std_logic;
		clk_in : in  std_logic;
		clk_out : out  std_logic;
		const : in INTEGER
	);
end clk_divider;

architecture clk_divider_arch of clk_divider is
	signal counter : integer := 0;
	signal clk_tp : std_logic := '0';
	
begin

	clk_out <= clk_tp;
	
	DIVIDER: process(clk_in, rst) is
	begin
		if (rst = '1') then
			counter <= 0;
			clk_tp <= '0';
		elsif (rising_edge(clk_in)) then
			if counter = const then
				counter <= 0;
				clk_tp <= not clk_tp;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process DIVIDER;

end clk_divider_arch;

