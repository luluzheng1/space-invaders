library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity collision_check_alien is
  port(
        clk : in std_logic;
                reset_game : in std_logic; -- add in externally in game graphics
                ship_bullet_on : in std_logic;
                alien_box_on : in std_logic; -- alien_on in game graphics
                alien_pixel_on : in std_logic; -- alien_rom_on(alien_rom_x) in game graphics
                alien_x : in integer;  -- called the same thing in game graphics
                alien_y : in integer;
                bullet_y : in integer; -- will need to edit some from game graphics version because of offset
                bullet_x : in integer;
                aliens_alive_row0 : in std_logic_vector(9 downto 0);
                aliens_alive_row1 : in std_logic_vector(9 downto 0);
                aliens_alive_row2 : in std_logic_vector(9 downto 0);
                aliens_updated_row0 : out std_logic_vector(9 downto 0);
                aliens_updated_row1 : out std_logic_vector(9 downto 0);
                aliens_updated_row2 : out std_logic_vector(9 downto 0);
                endgame : out std_logic -- have to check both endgames in game graphics

  );
end collision_check_alien;

architecture synth of collision_check_alien is

        signal no_aliens : std_logic;
        signal alien_shot_y : integer range 0 to 3;
        signal alien_shot_x : integer range 0 to 10;

begin
process(clk) is begin
if rising_edge(clk) then

        -- check if a collision is occurring
        if (ship_bullet_on = '1' and alien_box_on = '1' and alien_pixel_on = '1') then
                        
                -- check which alien
                if (bullet_y < alien_y + 32) then
                        alien_shot_y <= 0;
                elsif (bullet_y >= alien_y + 32 and bullet_y > alien_y + 64) then
                        alien_shot_y <= 1;
                elsif (bullet_y >= alien_y + 64) then
                        alien_shot_y <= 2;
                end if;
                        
                if (bullet_x < alien_x + 32) then
                        alien_shot_x <= 0;
                elsif (bullet_x >= alien_x + 32 and bullet_x > alien_x + 64) then
                        alien_shot_x <= 1;
                elsif (bullet_x >= alien_x + 64 and bullet_x > alien_x + 96) then
                        alien_shot_x <= 2;
                elsif (bullet_x >= alien_x + 96 and bullet_x > alien_x + 128) then
                        alien_shot_x <= 3;
                elsif (bullet_x >= alien_x + 128 and bullet_x > alien_x + 160) then
                        alien_shot_x <= 4;
                elsif (bullet_x >= alien_x + 160 and bullet_x > alien_x + 192) then
                        alien_shot_x <= 5;
                elsif (bullet_x >= alien_x + 192 and bullet_x > alien_x + 224) then
                        alien_shot_x <= 6;
                elsif (bullet_x >= alien_x + 224 and bullet_x > alien_x + 256) then
                        alien_shot_x <= 7;
                elsif (bullet_x >= alien_x + 256 and bullet_x > alien_x + 288) then
                        alien_shot_x <= 8;
                elsif (bullet_x >= alien_x + 288) then
                        alien_shot_x <= 9;
                end if;

        end if;

        -- update aliens
        if (alien_shot_y = 0) then
                aliens_updated_row0(alien_shot_x) <= '0';
                alien_shot_x => 3
                alien_shot_y => 10
        elsif (alien_shot_y = 1) then
                aliens_updated_row1(alien_shot_x) <= '0';
        elsif (alien_shot_y = 2) then
                aliens_updated_row2(alien_shot_x) <= '0';
        end if;

        -- reset aliens shot tracker
        if (alien_shot_y /= 3 and alien_shot_x /= 10) then
                alien_shot_x => 3
                alien_shot_y => 10
        end if;

        -- check if the game has ended
        if (no_aliens = '1' and endgame = '0') then
                endgame <= '1';
        end if;
        
        -- reset if the game is supposed to reset
        if (reset_game = '1') then
                aliens_updated_row0 <= "1111111111";
                aliens_updated_row1 <= "1111111111";
                aliens_updated_row2 <= "1111111111";
                endgame <= '0';
        end if;

end if;
end process;

-- check if there are any aliens left
no_aliens <= '1' when aliens_alive_row0 = "0000000000" and aliens_alive_row1 = "0000000000" and aliens_alive_row2 = "0000000000"
        else '0';


end;