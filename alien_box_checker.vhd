library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alien_box_checker is 
	port (
		clk : in std_logic; 
		alien_x : in integer;
        alien_y : in integer;
		alien_box_on : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
        alien_on_x : out integer range 0 to 10;
		alien_on_y : out integer range 0 to 3
	); 
end entity;
architecture synth of alien_box_checker is 

begin 
		process(clk) is 
			variable int_row : integer; 
			variable int_col : integer; 
		begin 
			int_row := to_integer(row);
			int_col := to_integer(col); 
		if rising_edge(clk) then
			if alien_box_on = '1' then
                if (int_row >= alien_y and int_row < alien_y + 32) then
                        alien_on_y <= 0;
                elsif (int_row >= alien_y + 32 and int_row < alien_y + 64) then
                        alien_on_y <= 1;
                elsif (int_row >= alien_y + 64 and int_row < alien_y + 96) then
                        alien_on_y <= 2;
				else
						alien_on_y <= 3;
                end if;
                        
                if (int_col >= alien_x and int_col < alien_x + 32) then
                        alien_on_x <= 0;
                elsif (int_col >= alien_x + 32 and int_col < alien_x + 64) then
                        alien_on_x <= 1;
                elsif (int_col >= alien_x + 64 and int_col < alien_x + 96) then
                        alien_on_x <= 2;
                elsif (int_col >= alien_x + 96 and int_col < alien_x + 128) then
                        alien_on_x <= 3;
                elsif (int_col >= alien_x + 128 and int_col < alien_x + 160) then
                        alien_on_x <= 4;
                elsif (int_col >= alien_x + 160 and int_col < alien_x + 192) then
                        alien_on_x <= 5;
                elsif (int_col >= alien_x + 192 and int_col < alien_x + 224) then
                        alien_on_x <= 6;
                elsif (int_col >= alien_x + 224 and int_col < alien_x + 256) then
                        alien_on_x <= 7;
                elsif (int_col >= alien_x + 256 and int_col < alien_x + 288) then
                        alien_on_x <= 8;
                elsif (int_col >= alien_x + 288 and int_col < alien_x + 320) then
                        alien_on_x <= 9;
				else
						alien_on_x <= 10;
                end if;
				
			end if;
		
			--if (alien_on_y /= 3 and alien_on_x /= 10) then
                --alien_on_y <= 3;
				--alien_on_x <= 10;
			--end if;
				
		end if;
		end process;
end; 

