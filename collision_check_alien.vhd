library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision_check_alien is
	port(
        clk : in std_logic;
		reset_game : in std_logic;
        ship_bullet_on : in std_logic;
        alien_box_on : in std_logic;
        alien_pixel_on : in std_logic;
        alien_x : in integer;
        alien_y : in integer;
        bullet_y : in unsigned(9 downto 0);
        bullet_x : in unsigned(9 downto 0);
        aliens_alive_row0 : in std_logic_vector(9 downto 0);
        aliens_alive_row1 : in std_logic_vector(9 downto 0);
        aliens_alive_row2 : in std_logic_vector(9 downto 0);
        aliens_updated_row0 : out std_logic_vector(9 downto 0);
        aliens_updated_row1 : out std_logic_vector(9 downto 0);
        aliens_updated_row2 : out std_logic_vector(9 downto 0);
        endgame : out std_logic;
		alien_hit : out std_logic;
		alien_activated : in std_logic
	);
end collision_check_alien;

architecture synth of collision_check_alien is

component alien_box_checker is 
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
end component;

signal no_aliens : std_logic;
signal alien_shot_y : integer range 0 to 3 := 3;
signal alien_shot_x : integer range 0 to 10 := 10;
signal alien_shot_y_latch : integer range 0 to 3 := 3;
signal alien_shot_x_latch : integer range 0 to 10 := 10;
signal alien_box_latch : std_logic := '0';
signal alien_x_latch : integer range 0 to 1023;
signal alien_y_latch : integer range 0 to 1023;
signal bullet_y_latch : unsigned(9 downto 0);
signal bullet_x_latch : unsigned(9 downto 0);
signal wait_cycle0 : std_logic := '0';
signal wait_cycle1 : std_logic := '0';
signal wait_cycle2 : std_logic := '0';
signal aliens_updated0_row0 : std_logic_vector(9 downto 0);
signal aliens_updated0_row1 : std_logic_vector(9 downto 0);
signal aliens_updated0_row2 : std_logic_vector(9 downto 0);
signal hit_in_progress : std_logic := '0';

begin

alien_finder : alien_box_checker port map (
	clk => clk,
	alien_x => alien_x_latch,
	alien_y => alien_y_latch,
	alien_box_on => alien_box_latch,
	row => bullet_y_latch,
	col => bullet_x_latch,
	alien_on_x => alien_shot_x,
	alien_on_y => alien_shot_y
);

process(clk) is begin
	if rising_edge(clk) then
	-- check if a collision is occurring
	if (ship_bullet_on = '1' and alien_box_on = '1' and alien_pixel_on = '1' and alien_activated = '1' and hit_in_progress = '0') then
		alien_hit <= '1';
		alien_box_latch <= '1';
		bullet_x_latch <= bullet_x;
		bullet_y_latch <= bullet_y;
		alien_x_latch <= alien_x;
		alien_y_latch <= alien_y;
		hit_in_progress <= '1';
	end if;

	if alien_hit = '1' then
		alien_hit <= '0';
		wait_cycle0 <= '1';
		aliens_updated0_row0 <= aliens_alive_row0;
		aliens_updated0_row1 <= aliens_alive_row1;
		aliens_updated0_row2 <= aliens_alive_row2;
	end if;
	
	if wait_cycle0 = '1' then
		wait_cycle0 <= '0';
		wait_cycle1 <= '1';
	end if;
	

	if wait_cycle1 = '1' then

		bullet_x_latch <= (others => '0');
		bullet_y_latch <= (others => '0');
		alien_x_latch <= 0;
		alien_y_latch <= 0;
		alien_box_latch <= '0';

		-- update alien
		if (alien_shot_y = 0) then
			aliens_updated0_row0(alien_shot_x) <= '0';
		elsif (alien_shot_y = 1) then
			aliens_updated0_row1(alien_shot_x) <= '0';
		elsif (alien_shot_y = 2) then
			aliens_updated0_row2(alien_shot_x) <= '0';
		end if; 
		
			wait_cycle1 <= '0';
			wait_cycle2 <= '1';

	end if;

	if wait_cycle2 = '1' then

		wait_cycle2 <= '0';
		aliens_updated_row0 <= aliens_updated0_row0;
		aliens_updated_row1 <= aliens_updated0_row1;
		aliens_updated_row2 <= aliens_updated0_row2;
		hit_in_progress <= '0';

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
alien_hit <= '0';
end if;

end if;
end process;

-- check if there are any aliens left
no_aliens <= '1' when aliens_alive_row0 = "0000000000" and aliens_alive_row1 = "0000000000" and aliens_alive_row2 = "0000000000"
else '0';


end;