----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu, Ben Olson - molson5@utk.edu
-- ECE-351: Course Project - Greenhouse Monitor
-- Notes: Button debouncing and control logic 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity btn_control is
   Port (
		clk : in  STD_LOGIC;
      rst : in  STD_LOGIC;
		btn_bus : in  STD_LOGIC_VECTOR (3 downto 0);
      output_bus : out  STD_LOGIC_VECTOR (3 downto 0));
end btn_control;

architecture btn_control_arch of btn_control is
	signal stage1, stage2 : std_logic_vector(3 downto 0) := "0000";
	signal lock : std_logic := '0';
begin
	
	--debounce the input buttons, and only allow one to pulse per press
	BTN_DEBOUNCE: process(clk, rst) is 
	begin
		if (rst = '1') then
			stage1 <= "0000";
			stage2 <= "0000";
			lock <= '0';
		elsif (rising_edge(clk)) then
			stage1 <= btn_bus;
			stage2 <= stage1;
			lock <= (stage2(3) or stage2(2) or stage2(1) or stage2(0));
		end if;
	end process BTN_DEBOUNCE;
	
	output_bus(3) <= stage1(3) and stage2(3) and (not lock);
	output_bus(2) <= stage1(2) and stage2(2) and (not lock);
	output_bus(1) <= stage1(1) and stage2(1) and (not lock);
	output_bus(0) <= stage1(0) and stage2(0) and (not lock);

end btn_control_arch;

