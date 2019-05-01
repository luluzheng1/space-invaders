library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision_check_ship is
  port(
        clk : in std_logic;
        reset_game : in std_logic;
        alien_bullet_on : in std_logic;
        ship_box_on : in std_logic;
        ship_pixel_on : in std_logic;
        endgame : out std_logic;
        lives : out integer range 0 to 2; 
		ship_hit : out std_logic;
		bullet_deactivated : in std_logic
  );
end collision_check_ship;

architecture synth of collision_check_ship is
        signal lives_left : integer range 0 to 2 := 2;
		signal hit : std_logic:= '0'; 
		signal can_check : std_logic := '1';
begin
	process(clk) is begin
	if rising_edge(clk) then
		if (alien_bullet_on = '1' and ship_box_on = '1' and ship_pixel_on = '1' and can_check = '1') then
			lives_left <= lives_left - 1;
			hit <= '1';
			can_check <= '0';
			if (lives_left = 0 and endgame = '0') then
				endgame <= '1';
			end if;
		end if;
		
		if hit = '1' then -- reset hit detector
			hit <= '0';
		end if;
					
		if (reset_game = '1') then
			lives_left <= 2;
			hit <= '0'; 
			endgame <= '0';
			can_check <= '1';
		end if;
		
		if (bullet_deactivated = '1') then
			can_check <= '1';
		end if;
		
	end if;
	end process;

	lives <= lives_left;
	ship_hit <= hit; 

end;