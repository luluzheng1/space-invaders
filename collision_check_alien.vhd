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

begin
process(clk) is begin
if rising_edge(clk) then

        if (ship_bullet_on = '1' and alien_box_on = '1' and alien_pixel_on = '1') then
                        -- check which alien
                        
                        case bullet_y is
                                when 
                        
                        
                        
                        
                        -- reference vvvvvvvvvv
                        
                        case random_y is 
                                when "00000" => alien_y <= input_y; 
                                when "00001" => alien_y <= input_y + 32; 
                                when "00010" => alien_y <= input_y + 64;
                                when others => alien_y <= 670; 
                        end case; 
                        
                        case random_x is 
                                when "00000" => alien_x <= input_x; 
                                when "00001" => alien_x <= input_x + 32; 
                                when "00010" => alien_x <= input_x + 64; 
                                when "00011" => alien_x <= input_x + 96; 
                                when "00100" => alien_x <= input_x + 128; 
                                when "00101" => alien_x <= input_x + 160; 
                                when "00110" => alien_x <= input_x + 192; 
                                when "00111" => alien_x <= input_x + 224; 
                                when "01000" => alien_x <= input_x + 256; 
                                when "01001" => alien_x <= input_x + 288; 
                                when others => alien_x <= 670; 
                        end case; 
                        
                        
                        --
                        
                        if (no_aliens = '1' and endgame = '0') then
                                endgame <= '1';
                        end if;
                end if;
                
                if (reset_game = '1') then
                        aliens_updated_row0 <= "1111111111";
                        aliens_updated_row1 <= "1111111111";
                        aliens_updated_row2 <= "1111111111";
                        endgame <= '0';
                end if;

end if;
end process;

no_aliens <= '1' when aliens_alive_row0 = "0000000000" and aliens_alive_row1 = "0000000000" and aliens_alive_row2 = "0000000000"
        else '0';

end;