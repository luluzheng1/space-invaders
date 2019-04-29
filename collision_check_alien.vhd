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
		--row : in unsigned(9 downto 0);
		--col : in unsigned(9 downto 0);

        bullet_y : in integer; -- will need to edit some from game graphics version because of offset
        bullet_x : in integer;
        aliens_alive_row0 : in std_logic_vector(9 downto 0);
        aliens_alive_row1 : in std_logic_vector(9 downto 0);
        aliens_alive_row2 : in std_logic_vector(9 downto 0);
        aliens_updated_row0 : out std_logic_vector(9 downto 0);
        aliens_updated_row1 : out std_logic_vector(9 downto 0);
        aliens_updated_row2 : out std_logic_vector(9 downto 0);
        endgame : out std_logic; -- have to check both endgames in game graphics
		alien_hit : out std_logic
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
signal bullet_y_latch : integer := 0;
signal bullet_x_latch : integer := 0;
signal wait_cycle : std_logic := '0';

begin

alien_finder : alien_box_checker port map (
	clk => clk,
	alien_x => alien_x,
	alien_y => alien_y,
	alien_box_on => alien_box_latch,
	row => to_unsigned(bullet_x_latch),
	col => to_unsigned(bullet_y_latch),
	alien_on_x => alien_shot_x,
	alien_on_y => alien_shot_y
);
		
	process(clk) is begin
	if rising_edge(clk) then
		-- check if a collision is occurring
		if (ship_bullet_on = '1' and alien_box_on = '1' and alien_pixel_on = '1') then

			alien_hit <= '1'; -- TESTING PURPOSES ONLY
			alien_box_latch <= '1';
			bullet_x_latch <= bullet_x;
			bullet_y_latch <= bullet_y;

		end if;
		
		if alien_box_latch = '1' then
			
			bullet_x_latch <= 0;
			bullet_y_latch <= 0;
			alien_box_latch <= '0';
			alien_hit <= '0';
			wait_cycle <= '1';
			
		end if;
		
		if wait_cycle = '1' then
		
		-- update alien
			if (alien_shot_y = 0) then
				aliens_updated_row0(alien_shot_x) <= '0';
			elsif (alien_shot_y = 1) then
				aliens_updated_row1(alien_shot_x) <= '0';
			elsif (alien_shot_y = 2) then
				aliens_updated_row2(alien_shot_x) <= '0';
			end if;	
			wait_cycle <= '0';
			
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