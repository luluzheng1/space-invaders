library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision_check is
  port(
        clk : in std_logic;
        reset_game : in std_logic; -- add in externally in game graphics
        alien_bullet_on : in std_logic;
        ship_box_on : in std_logic; -- ship_on in game graphics
        ship_pixel_on : in std_logic; -- rom_on(rom_x) in game graphics
        endgame : out std_logic; -- have to check both endgames in game graphics
        lives : out integer; 
		ship_hit : out std_logic
  );
end collision_check;

architecture synth of collision_check is
        signal lives_left : integer := 10;
		signal hit : std_logic:= '0'; 
begin
	process(clk) is begin
	if rising_edge(clk) then
		if (alien_bullet_on = '1' and ship_box_on = '1' and ship_pixel_on = '1') and lives_left > 0 then
			lives_left <= lives_left - 1;
			hit <= '1'; 
		else
			hit <= '0';
		end if;
					
		if (reset_game = '1') then
			lives_left <= 10;
			hit <= '0';
			endgame <= '0';
		end if;
		
	end if;
	end process;

	lives <= lives_left;
	ship_hit <= hit; 

end;