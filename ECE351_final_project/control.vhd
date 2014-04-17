----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu, Ben Olson - molson5@utk.edu
-- ECE-351: Course Project - Greenhouse Monitor
-- Notes: Project top module.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control is
	PORT(
		mclk : in std_logic; --main clock
		rst : in std_logic; --async reset
		swi_bus : in std_logic_vector(7 downto 0); --input from switches
		btn_bus : in std_logic_vector(3 downto 0); --input from buttons
		led_bus : out std_logic_vector(7 downto 0); --output to LEDs
		seg_bus : out std_logic_vector(0 to 7); --output to the 7-seg cathodes
		digi_bus : out std_logic_vector(0 to 3); --output to the 7-seg anodes
		als_clk : out std_logic;
		als_cs : out std_logic;
		als_sda : in std_logic
	); 
end control;

architecture control_arch of control is
	component clk_divider is
	   Port ( 
		rst: in std_logic;
		clk_in : in  std_logic;
		clk_out : out  std_logic;
		const : in INTEGER);
	end component clk_divider;
	
	component btn_control is
		Port (
			clk : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			btn_bus : in  STD_LOGIC_VECTOR (3 downto 0);
			output_bus : out  STD_LOGIC_VECTOR (3 downto 0));
	end component btn_control;
	
	component interface is
		Port ( 
		rst : in  std_logic;
      clk : in  std_logic;
      btn_bus : in  std_logic_vector (3 downto 0);
      t_data : in  std_logic_vector (7 downto 0);
      l_data : in  std_logic_vector (7 downto 0);
      seg_bus : out  std_logic_vector (0 to 7);
      digi_bus : out  std_logic_vector (0 to 3);
      led_bus : out  std_logic_vector (7 downto 0));
	end component interface;
	
	component als_driver is
	   Port (
		rst : in STD_LOGIC;
		clk : in STD_LOGIC;
		cs : out  STD_LOGIC;
      scl : out  STD_LOGIC;
      sda : in  STD_LOGIC;
      data_out : out  STD_LOGIC_VECTOR (7 downto 0));
	end component als_driver;
	
	signal btn_buffer : std_logic_vector(3 downto 0) := "0000";
	signal l_data, t_data : std_logic_vector(7 downto 0) := "00000000";
	
begin
	--l_data <= swi_bus;
	t_data <= swi_bus;
	
	SYS_MAIN: interface port map (
		rst => rst,
      clk => mclk,
      btn_bus => btn_buffer,
      t_data => t_data,
      l_data => l_data,
      seg_bus => seg_bus,
      digi_bus => digi_bus,
      led_bus => led_bus
	);
	
	DEBOUNCE: btn_control port map (
		clk => mclk,
      rst => rst,
		btn_bus => btn_bus,
      output_bus => btn_buffer
	);
	
	LIGHT_SENSOR: als_driver port map (
		rst => rst,
		clk => mclk,
		cs => als_cs,
      scl => als_clk,
      sda => als_sda,
      data_out => l_data
	);

end control_arch;

