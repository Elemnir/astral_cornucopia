----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu, Ben Olson - molson5@utk.edu
-- ECE-351: Course Project - Greenhouse Monitor
-- Notes: Driver for reading data from the Ambient Light Sensor
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity als_driver is
   Port (
		rst : in STD_LOGIC;
		clk : in STD_LOGIC;
		cs : out  STD_LOGIC;
      scl : out  STD_LOGIC;
      sda : in  STD_LOGIC;
      data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end als_driver;

architecture als_driver_arch of als_driver is
	component clk_divider is
	Port ( 
		rst: in std_logic;
		clk_in : in  std_logic;
		clk_out : out  std_logic;
		const : in INTEGER
	);
	end component clk_divider;
	
	signal cs_sig, sclk : std_logic := '1';
	signal w_counter : integer := 15;
	signal data_buffer : std_logic_vector (15 downto 0) := "0000000000000000";
	
begin
	
	scl <= sclk;
	cs <= cs_sig;
	data_out <= data_buffer(11 downto 4);
	
	-- Divides clock down to 2MHz
	CLK_DIV: clk_divider port map( 
		rst => rst,
		clk_in => clk,
		clk_out => sclk,
		const => 24
	);
	
	SPI_READ: process(sclk, rst) is
	begin
		if (rst = '1') then
			cs_sig <= '1';
			data_buffer <= "0000000000000000";
			w_counter <= 15;
		elsif rising_edge(sclk) then
			if w_counter = 15 then
				cs_sig <= '0';
				w_counter <= w_counter - 1;
			elsif w_counter > 0 then
				data_buffer(w_counter) <= sda;
				w_counter <= w_counter - 1;
			else
				data_buffer(w_counter) <= sda;
				cs_sig <= '1';
				w_counter <= 15;
			end if;
		end if;
	end process SPI_READ;
	
end als_driver_arch;

