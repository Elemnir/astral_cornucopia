----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu
-- Notes: Driver for reading data from the Digilent PModALS - Ambient Light Sensor
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
cs : out STD_LOGIC;
      scl : out STD_LOGIC;
      sda : in STD_LOGIC;
      data_out : out STD_LOGIC_VECTOR (7 downto 0));
end als_driver;

architecture als_driver_arch of als_driver is

	signal cs_sig, sclk : std_logic := '1';
	signal w_counter : integer := 15;
	signal data_buffer : std_logic_vector (15 downto 0) := "0000000000000000";
	signal const : integer := 24;
begin

	scl <= sclk;
	cs <= cs_sig;
	data_out <= data_buffer(11 downto 4);

	-- Divides clock down to 2MHz
	DIVIDER: process(clk, rst) is
	begin
		if (rst = '1') then
			counter <= 0;
			sclk <= '1';
		elsif (rising_edge(clk)) then
			if counter = const then
				counter <= 0;
				sclk <= not sclk;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process DIVIDER;


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