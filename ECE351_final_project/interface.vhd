----------------------------------------------------------------------------------
-- 
-- Author: Adam Howard - ahowar31@utk.edu, Ben Olson - molson5@utk.edu
-- ECE-351: Course Project - Greenhouse Monitor
-- Notes: Main interface controller 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity interface is
   Port ( 
		rst : in  std_logic;
      clk : in  std_logic;
      btn_bus : in  std_logic_vector (3 downto 0);
      t_data : in  std_logic_vector (7 downto 0);
      l_data : in  std_logic_vector (7 downto 0);
      seg_bus : out  std_logic_vector (0 to 7);
      digi_bus : out  std_logic_vector (0 to 3);
      led_bus : out  std_logic_vector (7 downto 0)
	);
end interface;

architecture interface_arch of interface is
	type DISPLAY_STATE is (t_cur, t_low, t_high, l_cur, l_low, l_high);
	signal disp : DISPLAY_STATE := t_cur;
	
	signal tl_set, ll_set : integer := 0; --default low temp and light settings
	signal th_set, lh_set : integer := 255; --default high temp and light settings
	signal alert : integer := 0; --if !=0, show system state on display
	
	component clk_divider is
		Port ( 
		rst: in std_logic;
		clk_in : in  std_logic;
		clk_out : out  std_logic;
		const : in INTEGER
	);
	end component clk_divider;
	
	signal clk_digi : std_logic := '0';
	signal digi_val : std_logic_vector(3 downto 0) := "1110";
	
begin
	digi_bus <= digi_val;
	
	DIG_DIV: clk_divider port map( 
		rst => rst,
		clk_in => clk,
		clk_out => clk_digi,
		const => 10000
	);
	
	-- 7-segment display driver
	DISP_DRIVER: process(clk_digi, rst, digi_val) is
		variable digi_temp : std_logic_vector(3 downto 0);
		variable temp_int, t : integer;
	begin
		digi_temp := digi_val;
		
		if (rst = '1') then
			digi_val <= "1110";
			seg_bus <= "00000000";
		elsif rising_edge(clk_digi) then
			digi_temp := digi_temp(2 downto 0) & digi_temp(3);
			
			-- Show 1st digit on display
			if (digi_temp(3) = '0') then
				if (disp = t_cur or disp = t_low or disp = t_high) then
					seg_bus <= "11001110";
				else
					seg_bus <= "11000111";
				end if;
			
			-- Show 2nd digit on display
			elsif (digi_temp(2) = '0') then
				if alert /= 0 then
					seg_bus <= "11111111";					
				else
					if disp = t_cur then
						temp_int := conv_integer(t_data);
					elsif disp = t_low then
						temp_int := tl_set;
					elsif disp = t_high then
						temp_int := th_set;
					elsif disp = l_cur then
						temp_int := conv_integer(l_data);
					elsif disp = l_low then
						temp_int := ll_set;
					else
						temp_int := lh_set;
					end if;
					
					if (temp_int < 200 and temp_int > 99) then 
						seg_bus <= "11111001";
					elsif (temp_int < 300 and temp_int > 199) then 
						seg_bus <= "10100100";
					else
						seg_bus <= "11111111";
					end if;
				end if;
			
			-- Show 3rd digit on display
			elsif (digi_temp(1) = '0') then
				if alert /= 0 then
					if (disp = t_cur or disp = l_cur) then
						seg_bus <= "11000110";
					elsif (disp = t_low or disp = l_low) then
						seg_bus <= "11000111";
					else
						seg_bus <= "10001001";
					end if;
					
				else
					if disp = t_cur then
						temp_int := conv_integer(t_data);
					elsif disp = t_low then
						temp_int := tl_set;
					elsif disp = t_high then
						temp_int := th_set;
					elsif disp = l_cur then
						temp_int := conv_integer(l_data);
					elsif disp = l_low then
						temp_int := ll_set;
					else
						temp_int := lh_set;
					end if;
					
					--temp_int := temp_int mod 100;
					if (temp_int > 200) then 
						temp_int := temp_int - 200;
					elsif (temp_int > 100) then
						temp_int := temp_int - 100;
					end if;
					
					if (temp_int < 20 and temp_int > 9) then
						seg_bus <= "11111001";
					elsif (temp_int < 30 and temp_int > 19) then	
						seg_bus <= "10100100";
					elsif (temp_int < 40 and temp_int > 29) then
						seg_bus <= "10110000";
					elsif (temp_int < 50 and temp_int > 39) then	
						seg_bus <= "10011001";
					elsif (temp_int < 60 and temp_int > 49) then
						seg_bus <= "10010010";
					elsif (temp_int < 70 and temp_int > 59) then	
						seg_bus <= "10000010";
					elsif (temp_int < 80 and temp_int > 69) then	
						seg_bus <= "11111000";
					elsif (temp_int < 90 and temp_int > 79) then	
						seg_bus <= "10000000";
					elsif (temp_int < 100 and temp_int > 89) then
						seg_bus <= "10010000";
					else
						seg_bus <= "11000000";
					end if;
				end if;
			
			-- Show 4th digit on display
			elsif (digi_temp(0) = '0') then
				if alert /= 0 then
					if (disp = t_cur or disp = l_cur) then
						seg_bus <= "11000001";
					elsif (disp = t_low or disp = l_low) then
						seg_bus <= "11000000";
					else
						seg_bus <= "11001111";
					end if;
					
				else
					if disp = t_cur then
						temp_int := conv_integer(t_data);
					elsif disp = t_low then
						temp_int := tl_set;
					elsif disp = t_high then
						temp_int := th_set;
					elsif disp = l_cur then
						temp_int := conv_integer(l_data);
					elsif disp = l_low then
						temp_int := ll_set;
					else
						temp_int := lh_set;
					end if;
					
					--temp_int := temp_int mod 10;
					if (temp_int > 200) then 
						temp_int := temp_int - 200;
					elsif (temp_int > 100) then
						temp_int := temp_int - 100;
					end if;
					
					if (temp_int > 90) then
						temp_int := temp_int - 90;
					elsif (temp_int > 80) then
						temp_int := temp_int - 80;
					elsif (temp_int > 70) then
						temp_int := temp_int - 70;
					elsif (temp_int > 60) then
						temp_int := temp_int - 60;
					elsif (temp_int > 50) then
						temp_int := temp_int - 50;
					elsif (temp_int > 40) then
						temp_int := temp_int - 40;
					elsif (temp_int > 30) then
						temp_int := temp_int - 30;
					elsif (temp_int > 20) then
						temp_int := temp_int - 20;
					elsif (temp_int > 10) then
						temp_int := temp_int - 10;
					end if;
					
					if (temp_int = 1) then
						seg_bus <= "11111001";
					elsif (temp_int = 2) then	
						seg_bus <= "10100100";
					elsif (temp_int = 3) then
						seg_bus <= "10110000";
					elsif (temp_int = 4) then	
						seg_bus <= "10011001";
					elsif (temp_int = 5) then
						seg_bus <= "10010010";
					elsif (temp_int = 6) then	
						seg_bus <= "10000010";
					elsif (temp_int = 7) then	
						seg_bus <= "11111000";
					elsif (temp_int = 8) then	
						seg_bus <= "10000000";
					elsif (temp_int = 9) then
						seg_bus <= "10010000";
					else
						seg_bus <= "11000000";
					end if;
				end if;
			end if;
			digi_val <= digi_temp;
		end if;
	end process DISP_DRIVER;
			
	
	-- Controls state changes and modifies system settings based on BTN input
	BTN_LOGIC: process(clk, rst) is
	begin
		if (rst = '1') then
			disp <= t_cur;
			alert <= 0;
			lh_set <= 255;
			th_set <= 255;
			ll_set <= 0;
			tl_set <= 0;
		elsif rising_edge(clk) then
			if alert /= 0 then
				alert <= alert - 1;
			end if;
			
			if btn_bus(3) = '1' then --switch from light read out to temp read out
				if (disp = t_cur or disp = t_low or disp = t_high) then
					disp <= l_cur;
				else
					disp <= t_cur;
				end if;
				alert <= 50000000;
			elsif btn_bus(2) = '1' then --switch between current, low, and, high readouts
				case (disp) is
					when t_cur => disp <= t_low;
					when t_low => disp <= t_high;
					when t_high => disp <= t_cur;
					when l_cur => disp <= l_low;
					when l_low => disp <= l_high;
					when l_high => disp <= l_cur;
				end case;
				alert <= 50000000;
			elsif btn_bus(1) = '1' then --increment the current setting
				if disp = t_low and tl_set < th_set-1 then
					tl_set <= tl_set + 1;
				elsif disp = t_high and th_set < 255 then
					th_set <= th_set + 1;
				elsif disp = l_low and ll_set < lh_set-1 then
					ll_set <= ll_set + 1;
				elsif disp = l_high and lh_set < 255 then
					lh_set <= lh_set + 1;
				end if;
			elsif btn_bus(0) = '1' then --decrement the current setting
				if disp = t_low and tl_set > 0 then
					tl_set <= tl_set - 1;
				elsif disp = t_high and th_set > tl_set + 1 then
					th_set <= th_set - 1;
				elsif disp = l_low and ll_set > 0 then
					ll_set <= ll_set - 1;
				elsif disp = l_high and lh_set > ll_set + 1 then
					lh_set <= lh_set - 1;
				end if;
			end if;
		end if;
	end process BTN_LOGIC;
	
	
	-- Activate LEDs if the light or temp data exceeds the set limits
	ALARM: process(clk, rst) is
		variable ttemp, ltemp : integer;
	begin
		ttemp := conv_integer(t_data);
		ltemp := conv_integer(l_data);
		
		if (rst = '1') then
			led_bus <= "00000000";
		elsif rising_edge(clk) then
			if (tl_set > ttemp) or (th_set < ttemp) then
				led_bus(0) <= '1';
			else
				led_bus(0) <= '0';
			end if;
			
			if (ll_set > ltemp) or (lh_set < ltemp) then
				led_bus(1) <= '1';
			else
				led_bus(1) <= '0';
			end if;
		end if;
	end process ALARM;

end interface_arch;

