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
		begin   
		if rising_edge(clk) then
			if alien_box_on = '1' then
                if (row >= to_unsigned(alien_y, 10) and row < to_unsigned(alien_y + 32, 10)) then
                        alien_on_y <= 0;
                elsif (row >= to_unsigned(alien_y + 32, 10) and row < to_unsigned(alien_y + 64, 10)) then
                        alien_on_y <= 1;
                elsif (row >= to_unsigned(alien_y + 64, 10) and row < to_unsigned(alien_y + 96, 10)) then
                        alien_on_y <= 2;
				else
						alien_on_y <= 3;
                end if;
                        
                if (col >= to_unsigned(alien_x, 10) and col < to_unsigned(alien_x + 32)) then
                        alien_on_x <= 0;
                elsif (col >= to_unsigned(alien_x + 32, 10) and col < to_unsigned(alien_x + 64, 10)) then
                        alien_on_x <= 1;
                elsif (col >= to_unsigned(alien_x + 64, 10) and col < to_unsigned(alien_x + 96, 10)) then
                        alien_on_x <= 2;
                elsif (col >= to_unsigned(alien_x + 96, 10) and col < to_unsigned(alien_x + 128, 10)) then
                        alien_on_x <= 3;
                elsif (col >= to_unsigned(alien_x + 128, 10) and col < to_unsigned(alien_x + 160, 10)) then
                        alien_on_x <= 4;
                elsif (col >= to_unsigned(alien_x + 160, 10) and col < to_unsigned(alien_x + 192, 10)) then
                        alien_on_x <= 5;
                elsif (col >= to_unsigned(alien_x + 192, 10) and col < to_unsigned(alien_x + 224, 10)) then
                        alien_on_x <= 6;
                elsif (col >= to_unsigned(alien_x + 224, 10) and col < to_unsigned(alien_x + 256, 10)) then
                        alien_on_x <= 7;
                elsif (col >= to_unsigned(alien_x + 256, 10) and col < to_unsigned(alien_x + 288, 10)) then
                        alien_on_x <= 8;
                elsif (col >= to_unsigned(alien_x + 288, 10) and col < to_unsigned(alien_x + 320, 10)) then
                        alien_on_x <= 9;
				else
						alien_on_x <= 10;
                end if;
				
			end if;			
		end if;
		end process;
		
end; 

